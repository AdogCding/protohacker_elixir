defmodule BudgetChatTest do
  @moduledoc """
  Problem 3: Budget Chat (https://protohackers.com/problem/3)

  - On connect the server sends a name prompt.
  - The first client message sets the user's name (alphanumeric, >= 1 char).
  - The new user receives a presence notification starting with '*',
    listing all present users except themselves (sent even if the room is empty).
  - Other joined users are told the user entered / left the room.
  - Chat messages are relayed to all other joined users as "[name] message".
  - Illegal names cause a disconnect without notifying anyone.
  """
  use ExUnit.Case, async: false

  @port 10_104

  setup do
    start_supervised!({ProtohackerElixir.Budget.Room, []})

    start_supervised!(
      {ProtohackerElixir.Generic.Server,
       port: @port,
       challenge: ProtohackerElixir.Budget.Client,
       task_type: :dynamic,
       socket_opts: [:binary, packet: :line, active: false, reuseaddr: true]}
    )

    on_exit(fn ->
      ProtohackerElixir.Generic.DynamicSupervisor
      |> DynamicSupervisor.which_children()
      |> Enum.each(fn {_id, child_pid, _type, _modules} ->
        if is_pid(child_pid) do
          DynamicSupervisor.terminate_child(
            ProtohackerElixir.Generic.DynamicSupervisor,
            child_pid
          )
        end
      end)
    end)

    %{port: @port}
  end

  defp connect(port) do
    {:ok, socket} =
      :gen_tcp.connect(~c"localhost", port, [:binary, packet: :line, active: false])

    socket
  end

  defp recv_line(socket, timeout \\ 2_000) do
    {:ok, line} = :gen_tcp.recv(socket, 0, timeout)
    line
  end

  defp join(port, name) do
    socket = connect(port)
    # The server prompts for a name upon connection
    assert String.contains?(recv_line(socket), "?")
    :ok = :gen_tcp.send(socket, "#{name}\n")
    # Presence notification: must start with '*' and must be sent even if room is empty
    presence = recv_line(socket)
    assert String.starts_with?(presence, "*")
    assert String.contains?(presence, "The room contains:")
    {socket, presence}
  end

  test "new user in an empty room receives a presence notification", %{port: port} do
    {socket, presence} = join(port, "alice")
    assert presence == "* The room contains: \n"
    :gen_tcp.close(socket)
  end

  test "joining user is announced to existing users and sees them in presence list", %{
    port: port
  } do
    {alice, _} = join(port, "alice")
    {bob, presence} = join(port, "bob")

    # alice is told bob entered the room
    entered = recv_line(alice)
    assert String.starts_with?(entered, "*")
    assert String.contains?(entered, "bob")
    assert String.contains?(entered, "entered")

    # bob's presence notification lists alice (but not himself)
    assert String.contains?(presence, "alice")
    refute String.contains?(presence, "bob")

    :gen_tcp.close(alice)
    :gen_tcp.close(bob)
  end

  test "chat messages are relayed to other users only, formatted as [name] message", %{
    port: port
  } do
    {alice, _} = join(port, "alice")
    {bob, _} = join(port, "bob")
    # Drain alice's "bob has entered" notification
    _ = recv_line(alice)

    :ok = :gen_tcp.send(bob, "hello alice\n")
    assert recv_line(alice) == "[bob] hello alice\n"

    # The server must not send the chat message back to the originating client
    :ok = :gen_tcp.send(alice, "hi bob\n")
    assert recv_line(bob) == "[alice] hi bob\n"
    assert {:error, :timeout} = :gen_tcp.recv(alice, 0, 300)

    :gen_tcp.close(alice)
    :gen_tcp.close(bob)
  end

  test "leaving user is announced to remaining users", %{port: port} do
    {alice, _} = join(port, "alice")
    {bob, _} = join(port, "bob")
    # Drain alice's "bob has entered" notification
    _ = recv_line(alice)

    :gen_tcp.close(bob)

    left = recv_line(alice)
    assert String.starts_with?(left, "*")
    assert String.contains?(left, "bob")
    assert String.contains?(left, "left")

    :gen_tcp.close(alice)
  end

  test "illegal name causes disconnect without announcing the user", %{port: port} do
    {alice, _} = join(port, "alice")

    socket = connect(port)
    _ = recv_line(socket)
    # Names must consist entirely of alphanumeric characters
    :ok = :gen_tcp.send(socket, "bad name!\n")

    assert {:error, :closed} = :gen_tcp.recv(socket, 0, 2_000)

    # alice must not hear anything about the illegal user
    assert {:error, :timeout} = :gen_tcp.recv(alice, 0, 500)

    :gen_tcp.close(alice)
  end

  test "empty name causes disconnect", %{port: port} do
    socket = connect(port)
    _ = recv_line(socket)
    :ok = :gen_tcp.send(socket, "\n")

    assert {:error, :closed} = :gen_tcp.recv(socket, 0, 2_000)
  end

  test "supports at least 10 simultaneous clients", %{port: port} do
    sockets =
      for i <- 1..10 do
        {socket, _} = join(port, "user#{i}")
        socket
      end

    # user k received one "entered the room" notification for each of the
    # (10 - k) users that joined after them; drain those first.
    sockets
    |> Enum.with_index(1)
    |> Enum.each(fn {socket, k} ->
      for _ <- 1..(10 - k)//1, do: recv_line(socket)
    end)

    [first | rest] = sockets
    :ok = :gen_tcp.send(first, "hello everyone\n")

    Enum.each(rest, fn socket ->
      assert recv_line(socket) == "[user1] hello everyone\n"
    end)

    Enum.each(sockets, &:gen_tcp.close/1)
  end
end
