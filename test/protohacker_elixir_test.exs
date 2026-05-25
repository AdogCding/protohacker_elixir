defmodule ProtohackerElixirTest do
  use ExUnit.Case
  doctest ProtohackerElixir

  test "is prime" do
    assert ProtohackerElixir.Prime.Helper.prime?(3) == true
    assert ProtohackerElixir.Prime.Helper.prime?(4) == false
  end

  test "is Boguscoin address" do
    assert ProtohackerElixir.Proxy.Helper.is_boguscoin_address?("7F1u3wSD5RbOHQmupo9nx4TnhQ") ==
             true

    assert ProtohackerElixir.Proxy.Helper.is_boguscoin_address?("7iKDZEwPZSqIvDnHvVN2r0hUWXD5rHX") ==
             true

    assert ProtohackerElixir.Proxy.Helper.is_boguscoin_address?(
             "7LOrwbDlS8NujgjddyogWgIM93MV5N2VR"
           ) ==
             true

    assert ProtohackerElixir.Proxy.Helper.is_boguscoin_address?(
             "7adNeSwJkMakpEcln9HEtthSRtxdmEHOT8T"
           ) ==
             true
  end
end
