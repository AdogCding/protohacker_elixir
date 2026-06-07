defmodule PrimeTest do
  use ExUnit.Case

  test "is prime" do
    assert ProtohackerElixir.Prime.Helper.prime?(3) == true
    assert ProtohackerElixir.Prime.Helper.prime?(4) == false
  end
end
