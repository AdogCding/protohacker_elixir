defmodule GenericToolsTest do
  @moduledoc """
  Unit tests for ProtohackerElixir.Generic.Tools (uuid generation helper).
  """
  use ExUnit.Case, async: true

  alias ProtohackerElixir.Generic.Tools

  describe "uuid/0,1" do
    test "default uuid is 32 lowercase hex characters" do
      uuid = Tools.uuid()
      assert String.length(uuid) == 32
      assert String.match?(uuid, ~r/^[0-9a-f]{32}$/)
    end

    test "uuid(:lower) is lowercase hex" do
      assert String.match?(Tools.uuid(:lower), ~r/^[0-9a-f]{32}$/)
    end

    test "uuid(:upper) is uppercase hex" do
      assert String.match?(Tools.uuid(:upper), ~r/^[0-9A-F]{32}$/)
    end

    test "generates unique values" do
      uuids = for _ <- 1..1000, into: MapSet.new(), do: Tools.uuid()
      assert MapSet.size(uuids) == 1000
    end
  end
end
