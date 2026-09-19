defmodule MeansToAnEndTest do
  @moduledoc """
  Problem 2: Means to an End (https://protohackers.com/problem/2)

  - Clients connect over TCP, each connection is a separate session/asset.
  - Each message is 9 raw bytes: 'I' | int32 timestamp | int32 price (big endian),
    or 'Q' | int32 mintime | int32 maxtime.
  - Query responds with a single int32: the mean price over [mintime, maxtime],
    or 0 if there are no samples in the period (or mintime > maxtime).
  """
  use ExUnit.Case, async: false

  alias ProtohackerElixir.Price.MeanQuery
  alias ProtohackerElixir.Price.PriceData
  alias ProtohackerElixir.Price.Worker

  @port 10_103

  # ---------------------------------------------------------------------------
  # Unit tests: binary protocol parsing
  # ---------------------------------------------------------------------------

  describe "handle_bytes/1" do
    test "parses an insert message" do
      # Spec example: I 12345 101 -> 49 00 00 30 39 00 00 00 65
      assert Worker.handle_bytes(<<?I, 12_345::signed-big-32, 101::signed-big-32>>) ==
               {:I, %PriceData{message_type: :insert, timestamp: 12_345, price: 101}}
    end

    test "parses an insert message with negative price (prices can go negative)" do
      assert Worker.handle_bytes(<<?I, 1000::signed-big-32, -500::signed-big-32>>) ==
               {:I, %PriceData{message_type: :insert, timestamp: 1000, price: -500}}
    end

    test "parses a query message" do
      # Spec example: Q 1000 100000 -> 51 00 00 03 e8 00 01 86 a0
      assert Worker.handle_bytes(<<?Q, 1000::signed-big-32, 100_000::signed-big-32>>) ==
               {:Q, %MeanQuery{mintime: 1000, maxtime: 100_000}}
    end

    test "returns error for an unknown message type" do
      assert Worker.handle_bytes(<<?X, 0::signed-big-32, 0::signed-big-32>>) ==
               {:error, "Error"}
    end

    test "returns error for a message that is too short" do
      assert Worker.handle_bytes(<<?I, 1, 2, 3>>) == {:error, "Error"}
    end
  end

  # ---------------------------------------------------------------------------
  # Unit tests: mean computation
  # ---------------------------------------------------------------------------

  describe "search_period/2" do
    defp price(timestamp, value) do
      %PriceData{message_type: :insert, timestamp: timestamp, price: value}
    end

    test "computes the mean of prices inside the closed interval" do
      data = [price(100, 10), price(200, 20), price(300, 30)]
      assert Worker.search_period(%MeanQuery{mintime: 100, maxtime: 300}, data) == 20
    end

    test "interval bounds are inclusive" do
      data = [price(100, 10), price(200, 20), price(300, 30)]
      # Only timestamp 100 matches
      assert Worker.search_period(%MeanQuery{mintime: 50, maxtime: 100}, data) == 10
      # Only timestamp 300 matches
      assert Worker.search_period(%MeanQuery{mintime: 300, maxtime: 350}, data) == 30
    end

    test "returns 0 when no samples fall inside the period" do
      data = [price(100, 10)]
      assert Worker.search_period(%MeanQuery{mintime: 200, maxtime: 300}, data) == 0
    end

    test "returns 0 when there is no data at all" do
      assert Worker.search_period(%MeanQuery{mintime: 0, maxtime: 1_000_000}, []) == 0
    end

    test "returns 0 when mintime comes after maxtime" do
      data = [price(100, 10), price(200, 20)]
      assert Worker.search_period(%MeanQuery{mintime: 300, maxtime: 50}, data) == 0
    end

    test "handles negative prices" do
      data = [price(100, -10), price(200, -20)]
      assert Worker.search_period(%MeanQuery{mintime: 0, maxtime: 1000}, data) == -15
    end

    test "non-integer mean is rounded (either direction is acceptable per spec)" do
      data = [price(100, 1), price(200, 2)]
      mean = Worker.search_period(%MeanQuery{mintime: 0, maxtime: 1000}, data)
      assert mean in [1, 2]
    end
  end

  # ---------------------------------------------------------------------------
  # Integration tests: full TCP server
  # ---------------------------------------------------------------------------

  describe "TCP server" do
    setup do
      start_supervised!(
        {ProtohackerElixir.Generic.Server,
         port: @port,
         challenge: Worker,
         task_type: :task,
         socket_opts: [:binary, :inet, active: false, reuseaddr: true]}
      )

      on_exit(fn ->
        ProtohackerElixir.Generic.TaskSupervisor
        |> Task.Supervisor.children()
        |> Enum.each(fn
          {pid} ->
            Task.Supervisor.terminate_child(ProtohackerElixir.Generic.TaskSupervisor, pid)

          pid when is_pid(pid) ->
            Task.Supervisor.terminate_child(ProtohackerElixir.Generic.TaskSupervisor, pid)
        end)
      end)

      %{port: @port}
    end

    defp connect(port) do
      {:ok, socket} = :gen_tcp.connect(~c"localhost", port, [:binary, active: false])
      socket
    end

    defp insert(socket, timestamp, price) do
      :gen_tcp.send(socket, <<?I, timestamp::signed-big-32, price::signed-big-32>>)
    end

    defp query(socket, mintime, maxtime) do
      :ok = :gen_tcp.send(socket, <<?Q, mintime::signed-big-32, maxtime::signed-big-32>>)
      {:ok, <<mean::signed-big-32>>} = :gen_tcp.recv(socket, 4, 2_000)
      mean
    end

    test "replays the example session from the problem statement", %{port: port} do
      socket = connect(port)

      insert(socket, 12_345, 101)
      insert(socket, 12_346, 102)
      insert(socket, 12_347, 100)
      insert(socket, 40_960, 5)

      assert query(socket, 12_288, 16_384) == 101

      :gen_tcp.close(socket)
    end

    test "query with no matching samples returns 0", %{port: port} do
      socket = connect(port)

      insert(socket, 100, 42)
      assert query(socket, 200, 300) == 0

      :gen_tcp.close(socket)
    end

    test "query on a fresh session returns 0", %{port: port} do
      socket = connect(port)
      assert query(socket, 0, 1_000_000) == 0
      :gen_tcp.close(socket)
    end

    test "handles negative prices over the wire", %{port: port} do
      socket = connect(port)

      insert(socket, 100, -100)
      insert(socket, 200, -50)
      assert query(socket, 0, 1000) == -75

      :gen_tcp.close(socket)
    end

    test "each session only sees its own data", %{port: port} do
      socket_a = connect(port)
      socket_b = connect(port)

      insert(socket_a, 100, 1000)

      # Client B inserted nothing, so its mean must be 0
      assert query(socket_b, 0, 1000) == 0
      # Client A still sees its own data
      assert query(socket_a, 0, 1000) == 1000

      :gen_tcp.close(socket_a)
      :gen_tcp.close(socket_b)
    end

    test "supports at least 5 simultaneous clients", %{port: port} do
      sockets = for _ <- 1..5, do: connect(port)

      sockets
      |> Enum.with_index()
      |> Enum.each(fn {socket, i} ->
        insert(socket, 100, i * 10)
      end)

      sockets
      |> Enum.with_index()
      |> Enum.each(fn {socket, i} ->
        assert query(socket, 0, 1000) == i * 10
      end)

      Enum.each(sockets, &:gen_tcp.close/1)
    end

    test "multiple messages can be pipelined in a single send", %{port: port} do
      socket = connect(port)

      # Two inserts and one query sent as one 27-byte chunk
      :ok =
        :gen_tcp.send(socket, [
          <<?I, 1::signed-big-32, 10::signed-big-32>>,
          <<?I, 2::signed-big-32, 20::signed-big-32>>,
          <<?Q, 0::signed-big-32, 100::signed-big-32>>
        ])

      {:ok, <<mean::signed-big-32>>} = :gen_tcp.recv(socket, 4, 2_000)
      assert mean == 15

      :gen_tcp.close(socket)
    end
  end
end
