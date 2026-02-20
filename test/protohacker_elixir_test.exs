defmodule ProtohackerElixirTest do
  use ExUnit.Case
  doctest ProtohackerElixir

  test "is prime" do
    assert ProtohackerElixir.Prime.Helper.prime?(3) == true
    assert ProtohackerElixir.Prime.Helper.prime?(4) == false
  end

  test "price" do
    {:ok, socket} =
      :gen_tcp.connect(~c"localhost", 10003, [
        :binary,
        packet: :raw,
        active: false
      ])

    price = 100
    timestamp = 12345
    assert :ok == :gen_tcp.send(socket, <<?I, timestamp::32, price::32>>)
    min_time = 12345
    max_time = 12346
    assert :ok == :gen_tcp.send(socket, <<?Q, min_time::32, max_time::32>>)
    :gen_tcp.close(socket)
  end
end
