defmodule ProtohackerElixir.Speed.DataType.Parser do
  alias ProtohackerElixir.Speed.DataType.WantHeartbeat
  alias ProtohackerElixir.Speed.DataType.Ticket
  alias ProtohackerElixir.Speed.DataType.Plate
  alias ProtohackerElixir.Speed.DataType.IAmDispatcher
  alias ProtohackerElixir.Speed.DataType.IAmCamera
  alias ProtohackerElixir.Speed.DataType.Heartbeat
  alias ProtohackerElixir.Speed.DataType.Error

  @type data_type ::
          Error.t()
          | Heartbeat.t()
          | IAmCamera.t()
          | IAmDispatcher.t()
          | Plate.t()
          | Ticket.t()
          | WantHeartbeat.t()

  @spec parse(binary) :: {:ok, {integer(), data_type()}} | {:error, term()}
  def parse(<<type_of_msg::unsigned-8, size_of_msg::unsigned-8, real_msg_bytes::binary>>) do
    <<first_n_bytes::binary-size(size_of_msg), rest_msg::binary>> = real_msg_bytes
    {:error, :not_implemented}
  end
end
