defmodule PrimeTest do
  use ExUnit.Case

  test "is prime" do
    assert ProtohackerElixir.Prime.Helper.prime?(1) == false
    assert ProtohackerElixir.Prime.Helper.prime?(2) == true
    assert ProtohackerElixir.Prime.Helper.prime?(3) == true
    assert ProtohackerElixir.Prime.Helper.prime?(4) == false
    assert ProtohackerElixir.Prime.Helper.prime?(5) == true
    assert ProtohackerElixir.Prime.Helper.prime?(6) == false
    assert ProtohackerElixir.Prime.Helper.prime?(5.22) == false
  end
end
