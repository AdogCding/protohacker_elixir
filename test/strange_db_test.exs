defmodule StrangeDbTest do
  @moduledoc """
  Problem 4: Unusual Database Program (https://protohackers.com/problem/4)

  - Key-value store over UDP. Each request/response is a single UDP packet.
  - Insert: request contains '='. The first '=' separates key from value.
    Keys cannot contain '='; values can. The empty string is a valid key.
    Insert yields no response. Re-inserting an existing key updates the value.
  - Retrieve: request has no '='. Server replies "key=value" to the sender.
    A missing key may reply "key=" or nothing at all.
  - Special key "version": non-empty, and attempts to modify it are ignored.
  """
  use ExUnit.Case, async: false

  alias ProtohackerElixir.StrangeDb.DbCmd
  alias ProtohackerElixir.StrangeDb.DbCmdHandler
  alias ProtohackerElixir.StrangeDb.DbServer
  alias ProtohackerElixir.StrangeDb.DbAcceptor

  @version "Keyang's 2026"
  @udp_port 10_105

  # ---------------------------------------------------------------------------
  # Unit tests: command parsing
  # ---------------------------------------------------------------------------

  describe "parse_cmd/1" do
    test "foo=bar is an insert" do
      assert DbCmdHandler.parse_cmd("foo=bar") ==
               {:ok, %DbCmd{cmd: :insert, key: "foo", value: "bar"}}
    end

    test "only the first '=' separates key from value" do
      assert DbCmdHandler.parse_cmd("foo=bar=baz") ==
               {:ok, %DbCmd{cmd: :insert, key: "foo", value: "bar=baz"}}
    end

    test "foo=== keeps the trailing equals in the value" do
      assert DbCmdHandler.parse_cmd("foo===") ==
               {:ok, %DbCmd{cmd: :insert, key: "foo", value: "=="}}
    end

    test "an empty value is allowed" do
      assert DbCmdHandler.parse_cmd("foo=") ==
               {:ok, %DbCmd{cmd: :insert, key: "foo", value: ""}}
    end

    test "the empty string is a valid key" do
      assert DbCmdHandler.parse_cmd("=foo") ==
               {:ok, %DbCmd{cmd: :insert, key: "", value: "foo"}}
    end

    test "a request without '=' is a retrieve" do
      assert DbCmdHandler.parse_cmd("message") ==
               {:ok, %DbCmd{cmd: :retrieve, key: "message"}}
    end
  end

  # ---------------------------------------------------------------------------
  # Unit tests: the DbServer GenServer
  # ---------------------------------------------------------------------------

  describe "DbServer" do
    setup do
      pid = start_supervised!({DbServer, [version: @version]})
      %{db: pid}
    end

    test "exposes a non-empty version", %{} do
      assert DbServer.retrieve("version") == {"version", @version}
    end

    test "insert then retrieve returns the stored value", %{} do
      :ok = insert_sync("foo", "bar")
      assert DbServer.retrieve("foo") == {"foo", "bar"}
    end

    test "re-inserting an existing key updates the value", %{} do
      :ok = insert_sync("foo", "bar")
      :ok = insert_sync("foo", "baz")
      assert DbServer.retrieve("foo") == {"foo", "baz"}
    end

    test "attempts to modify the version are ignored", %{} do
      :ok = insert_sync("version", "hacked")
      assert DbServer.retrieve("version") == {"version", @version}
    end

    test "retrieving a missing key yields a nil value", %{} do
      assert DbServer.retrieve("nope") == {"nope", nil}
    end

    # DbServer.insert/2 is a cast; wrap it in a call so the test is synchronous.
    defp insert_sync(key, value) do
      DbServer.insert(key, value)
      _ = :sys.get_state(DbServer)
      :ok
    end
  end

  # ---------------------------------------------------------------------------
  # Integration tests: the UDP acceptor
  # ---------------------------------------------------------------------------

  describe "UDP protocol" do
    setup do
      start_supervised!({DbServer, [version: @version]})
      start_supervised!({DbAcceptor, [port: @udp_port]})

      {:ok, client} = :gen_udp.open(0, [:binary, active: false])
      on_exit(fn -> :gen_udp.close(client) end)

      %{client: client, port: @udp_port}
    end

    defp send_only(client, port, request) do
      :ok = :gen_udp.send(client, ~c"127.0.0.1", port, request)
    end

    defp request(client, port, payload) do
      :ok = :gen_udp.send(client, ~c"127.0.0.1", port, payload)
      {:ok, {_ip, _from_port, response}} = :gen_udp.recv(client, 0, 2_000)
      response
    end

    test "insert yields no response, retrieve returns key=value", %{client: c, port: p} do
      send_only(c, p, "foo=bar")
      # Give the acceptor a moment to process the insert before retrieving.
      assert request(c, p, "foo") == "foo=bar"
    end

    test "version is reported and cannot be overwritten", %{client: c, port: p} do
      assert request(c, p, "version") == "version=#{@version}"

      send_only(c, p, "version=hacked")
      assert request(c, p, "version") == "version=#{@version}"
    end

    test "value may contain '=' characters", %{client: c, port: p} do
      send_only(c, p, "foo=bar=baz")
      assert request(c, p, "foo") == "foo=bar=baz"
    end

    test "re-inserting updates the returned value", %{client: c, port: p} do
      send_only(c, p, "k=first")
      send_only(c, p, "k=second")
      assert request(c, p, "k") == "k=second"
    end

    test "the empty string is a valid key", %{client: c, port: p} do
      send_only(c, p, "=foo")
      assert request(c, p, "") == "=foo"
    end

    test "retrieving a missing key produces no response", %{client: c, port: p} do
      :ok = :gen_udp.send(c, ~c"127.0.0.1", p, "does-not-exist")
      assert {:error, :timeout} = :gen_udp.recv(c, 0, 500)
    end
  end
end
