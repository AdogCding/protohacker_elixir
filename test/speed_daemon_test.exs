defmodule SpeedDaemonTest do
  alias ProtohackerElixir.Speed.DataType.BadMessage
  alias ProtohackerElixir.Speed.Witness
  alias ProtohackerElixir.Speed.SpeedLimitHelper
  alias ProtohackerElixir.Speed.DataType.Plate
  alias ProtohackerElixir.Speed.DataType.Error
  alias ProtohackerElixir.Speed.DataType.Ticket
  alias ProtohackerElixir.Speed.DataType
  alias ProtohackerElixir.Speed.Serializable
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

  test "parse ticket message" do
    ticket_message =
      <<0x21, 0x04, 0x55, 0x4E, 0x31, 0x58, 0x00, 0x42, 0x00, 0x64, 0x00, 0x01, 0xE2, 0x40, 0x00,
        0x6E, 0x00, 0x01, 0xE3, 0xA8, 0x27, 0x10>>

    ticket = %Ticket{
      plate: "UN1X",
      road: 66,
      mile1: 100,
      timestamp1: 123_456,
      mile2: 110,
      timestamp2: 123_816,
      speed: 10000
    }

    assert DataType.parse(ticket_message) == {:ok, ticket, <<>>}

    ticket_message =
      <<
        0x21,
        0x07,
        0x52,
        0x45,
        0x30,
        0x35,
        0x42,
        0x4B,
        0x47,
        0x01,
        0x70,
        0x04,
        0xD2,
        0x00,
        0x0F,
        0x42,
        0x40,
        0x04,
        0xD3,
        0x00,
        0x0F,
        0x42,
        0x7C,
        0x17,
        0x70
      >>

    ticket = %Ticket{
      plate: "RE05BKG",
      road: 368,
      mile1: 1234,
      timestamp1: 1_000_000,
      mile2: 1235,
      timestamp2: 1_000_060,
      speed: 6000
    }

    assert DataType.parse(ticket_message) == {:ok, ticket, <<>>}

    assert DataType.parse_all(<<ticket_message::binary, ticket_message::binary, 0x01>>) ==
             {[ticket, ticket, %BadMessage{}], <<0x01>>}
  end

  test "encode string message" do
    assert Serializable.Helper.encode_str("bad") == <<0x03, 0x62, 0x61, 0x64>>
  end

  test "is exceed speed limit" do
    assert SpeedLimitHelper.exceed_limit?(
             %Witness{
               plate: "TEST01",
               mile1: 8,
               timestamp1: 0,
               mile2: 9,
               timestamp2: 45
             },
             60
           ) == true
  end

  test "test want heartbeat" do
  end
end
