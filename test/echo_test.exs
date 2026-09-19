defmodule EchoTest do
  @moduledoc """
  Problem 0: Smoke Test (https://protohackers.com/problem/0)

  - Accept TCP connections.
  - Whenever you receive data from a client, send it back unmodified.
  - Don't mangle binary data, handle at least 5 simultaneous clients.
  """
  use ExUnit.Case, async: false

  @port 10_101

  setup do
    start_supervised!(
      {ProtohackerElixir.Generic.Server,
       port: @port,
       challenge: ProtohackerElixir.Echo.Worker,
       task_type: :task,
       socket_opts: [:binary, packet: :line, active: false, reuseaddr: true]}
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
    {:ok, socket} =
      :gen_tcp.connect(~c"localhost", port, [:binary, packet: :line, active: false])

    socket
  end

  defp echo(socket, data) do
    :ok = :gen_tcp.send(socket, data)
    {:ok, response} = :gen_tcp.recv(socket, 0, 2_000)
    response
  end

  test "echoes a single line back unmodified", %{port: port} do
    socket = connect(port)
    assert echo(socket, "hello\n") == "hello\n"
    :gen_tcp.close(socket)
  end

  test "echoes multiple lines in one session", %{port: port} do
    socket = connect(port)

    assert echo(socket, "first line\n") == "first line\n"
    assert echo(socket, "second line\n") == "second line\n"
    assert echo(socket, "third line\n") == "third line\n"

    :gen_tcp.close(socket)
  end

  test "does not mangle binary data", %{port: port} do
    socket = connect(port)

    binary_line = <<0, 1, 2, 127, 128, 200, 255, "abc">> <> "\n"
    assert echo(socket, binary_line) == binary_line

    :gen_tcp.close(socket)
  end

  test "handles at least 5 simultaneous clients", %{port: port} do
    sockets = for _ <- 1..5, do: connect(port)

    sockets
    |> Enum.with_index()
    |> Enum.each(fn {socket, i} ->
      assert echo(socket, "client-#{i}\n") == "client-#{i}\n"
    end)

    Enum.each(sockets, &:gen_tcp.close/1)
  end

  test "server keeps accepting new connections after a client disconnects", %{port: port} do
    socket = connect(port)
    assert echo(socket, "bye\n") == "bye\n"
    :gen_tcp.close(socket)

    # A brand new connection must still be served
    socket2 = connect(port)
    assert echo(socket2, "hello again\n") == "hello again\n"
    :gen_tcp.close(socket2)
  end
end
