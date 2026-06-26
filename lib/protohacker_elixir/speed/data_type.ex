defmodule ProtohackerElixir.Speed.DataType do
  alias ProtohackerElixir.Speed.DataType.BadMessage
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

  # 读取buffer数据，返回符合协议数据格式的信息
  @spec parse_all(binary()) :: {[data_type()], binary()}
  def parse_all(bytes) do
    {message_list, rest_bytes} = do_parse_all(bytes, {[], <<>>})
    {message_list |> Enum.reverse(), rest_bytes}
  end

  defp do_parse_all(<<>>, res) do
    res
  end

  defp do_parse_all(bytes, {msg_list, _}) do
    case parse(bytes) do
      {:ok, msg, rest_bytes} ->
        do_parse_all(rest_bytes, {[msg | msg_list], rest_bytes})

      {:error, :incomplete} ->
        do_parse_all(<<>>, {msg_list, bytes})

      {:error, _unknown_type} ->
        do_parse_all(<<>>, {[%BadMessage{} | msg_list], bytes})
    end
  end

  # read bytes and construct a data, return rest of bytes
  @spec parse(binary) ::
          {:ok, data_type(), binary()} | {:error, :unknown_type} | {:error, :incomplete}
  def parse(<<type_of_msg::unsigned-8, real_msg_bytes::binary>>) do
    case type_of_msg do
      0x10 -> Error.new(real_msg_bytes)
      0x20 -> Plate.new(real_msg_bytes)
      0x21 -> Ticket.new(real_msg_bytes)
      0x40 -> WantHeartbeat.new(real_msg_bytes)
      0x41 -> Heartbeat.new(real_msg_bytes)
      0x80 -> IAmCamera.new(real_msg_bytes)
      0x81 -> IAmDispatcher.new(real_msg_bytes)
      _ -> {:error, :unknown_type}
    end
  end
end
