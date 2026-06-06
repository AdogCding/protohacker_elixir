defmodule SpeedDaemonTest do
  alias ProtohackerElixir.Speed.DataType.Plate
  alias ProtohackerElixir.Speed.DataType.Error
  alias ProtohackerElixir.Speed.DataType
  use ExUnit.Case

  test "parse error message" do
    assert DataType.parse(<<0x10, 0x03, 0x62, 0x61, 0x64>>) == {:ok, %Error{msg: "bad"}, <<>>}
  end

  test "parse plate message" do
    assert DataType.parse(<<0x20, 0x04, 0x55, 0x4E, 0x31, 0x58, 0x00, 0x00, 0x03, 0xE8>>) ==
             {:ok, %Plate{plate: "UN1X", timestamp: 1000}, <<>>}

    assert DataType.parse(
             <<0x20, 0x07, 0x52, 0x45, 0x30, 0x35, 0x42, 0x4B, 0x47, 0x00, 0x01, 0xE2, 0x40>>
           ) ==
             {:ok, %Plate{plate: "RE05BKG", timestamp: 123_456}, <<>>}
  end
end
