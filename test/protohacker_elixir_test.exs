defmodule ProtohackerElixirTest do
  use ExUnit.Case
  doctest ProtohackerElixir

  test "greets the world" do
    assert ProtohackerElixir.hello() == :world
  end
end
