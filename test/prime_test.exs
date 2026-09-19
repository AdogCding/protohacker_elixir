defmodule PrimeTest do
  @moduledoc """
  Problem 1: Prime Time (https://protohackers.com/problem/1)

  - JSON-based request-response protocol over TCP, one JSON object per line.
  - Conforming request: {"method":"isPrime","number":<number>}.
    Any JSON number is valid, including floats. Extraneous fields are ignored.
  - Conforming response: {"method":"isPrime","prime":<bool>}.
    Non-integers can not be prime.
  - Malformed request -> send a single malformed response and disconnect.
  - At least 5 simultaneous clients.
  """
  use ExUnit.Case, async: false

  alias ProtohackerElixir.Prime.Helper
  alias ProtohackerElixir.Prime.Worker

  @port 10_102

  # ---------------------------------------------------------------------------
  # Unit tests: primality helper
  # ---------------------------------------------------------------------------

  describe "Helper.prime?/1" do
    test "small numbers" do
      refute Helper.prime?(-1)
      refute Helper.prime?(0)
      refute Helper.prime?(1)
      assert Helper.prime?(2)
      assert Helper.prime?(3)
      refute Helper.prime?(4)
      assert Helper.prime?(5)
      refute Helper.prime?(6)
      assert Helper.prime?(7)
      assert Helper.prime?(13)
      refute Helper.prime?(15)
    end

    test "larger primes and composites" do
      assert Helper.prime?(7_919)
      refute Helper.prime?(7_920)
      assert Helper.prime?(104_729)
      refute Helper.prime?(104_730)
    end

    test "perfect squares of primes are not prime" do
      refute Helper.prime?(49)
      refute Helper.prime?(121)
      refute Helper.prime?(169)
    end

    test "non-integers can not be prime" do
      refute Helper.prime?(5.22)
      refute Helper.prime?(2.0)
      refute Helper.prime?("7")
      refute Helper.prime?(nil)
    end
  end

  # ---------------------------------------------------------------------------
  # Integration tests: full TCP server
  # ---------------------------------------------------------------------------

  setup do
    start_supervised!(
      {ProtohackerElixir.Generic.Server,
       port: @port,
       challenge: Worker,
       task_type: :task,
       socket_opts: [
         :binary,
         :inet,
         packet: :line,
         active: false,
         buffer: 1024 * 1024,
         reuseaddr: true
       ]}
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

  defp ask(socket, request_line) do
    :ok = :gen_tcp.send(socket, request_line)
    {:ok, response} = :gen_tcp.recv(socket, 0, 5_000)
    Jason.decode!(String.trim(response))
  end

  test "responds to a conforming request", %{port: port} do
    socket = connect(port)

    assert ask(socket, ~s({"method":"isPrime","number":123}\n)) ==
             %{"method" => "isPrime", "prime" => false}

    assert ask(socket, ~s({"method":"isPrime","number":1234567890}\n)) ==
             %{"method" => "isPrime", "prime" => false}

    :gen_tcp.close(socket)
  end

  test "handles multiple requests in a single session", %{port: port} do
    socket = connect(port)

    for {n, expected} <- [{2, true}, {4, false}, {7919, true}, {1, false}, {0, false}] do
      assert ask(socket, ~s({"method":"isPrime","number":#{n}}\n)) ==
               %{"method" => "isPrime", "prime" => expected}
    end

    :gen_tcp.close(socket)
  end

  test "negative numbers are not prime", %{port: port} do
    socket = connect(port)

    assert ask(socket, ~s({"method":"isPrime","number":-7}\n)) ==
             %{"method" => "isPrime", "prime" => false}

    :gen_tcp.close(socket)
  end

  test "floating point numbers are never prime", %{port: port} do
    socket = connect(port)

    assert ask(socket, ~s({"method":"isPrime","number":5.22}\n)) ==
             %{"method" => "isPrime", "prime" => false}

    :gen_tcp.close(socket)
  end

  test "extraneous fields are ignored", %{port: port} do
    socket = connect(port)

    assert ask(socket, ~s({"method":"isPrime","number":13,"extra":"ignore me","x":42}\n)) ==
             %{"method" => "isPrime", "prime" => true}

    :gen_tcp.close(socket)
  end

  test "malformed JSON gets an error response and a disconnect", %{port: port} do
    socket = connect(port)

    :ok = :gen_tcp.send(socket, "this is not json\n")
    {:ok, response} = :gen_tcp.recv(socket, 0, 5_000)
    assert is_map(Jason.decode!(response))

    # The server must disconnect the client after a malformed request
    assert {:error, :closed} = :gen_tcp.recv(socket, 0, 5_000)
  end

  test "wrong method name gets an error response and a disconnect", %{port: port} do
    socket = connect(port)

    :ok = :gen_tcp.send(socket, ~s({"method":"notIsPrime","number":7}\n))
    {:ok, response} = :gen_tcp.recv(socket, 0, 5_000)
    assert is_map(Jason.decode!(response))

    assert {:error, :closed} = :gen_tcp.recv(socket, 0, 5_000)
  end

  test "non-number 'number' field gets an error response and a disconnect", %{port: port} do
    socket = connect(port)

    :ok = :gen_tcp.send(socket, ~s({"method":"isPrime","number":"seven"}\n))
    {:ok, response} = :gen_tcp.recv(socket, 0, 5_000)
    assert is_map(Jason.decode!(response))

    assert {:error, :closed} = :gen_tcp.recv(socket, 0, 5_000)
  end

  test "missing required field gets an error response and a disconnect", %{port: port} do
    socket = connect(port)

    :ok = :gen_tcp.send(socket, ~s({"method":"isPrime"}\n))
    {:ok, response} = :gen_tcp.recv(socket, 0, 5_000)
    assert is_map(Jason.decode!(response))

    assert {:error, :closed} = :gen_tcp.recv(socket, 0, 5_000)
  end

  test "handles at least 5 simultaneous clients", %{port: port} do
    sockets = for _ <- 1..5, do: connect(port)

    Enum.each(sockets, fn socket ->
      assert ask(socket, ~s({"method":"isPrime","number":97}\n)) ==
               %{"method" => "isPrime", "prime" => true}
    end)

    Enum.each(sockets, &:gen_tcp.close/1)
  end
end
