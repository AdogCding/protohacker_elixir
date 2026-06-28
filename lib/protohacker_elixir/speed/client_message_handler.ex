defmodule ProtohackerElixir.Speed.ClientMessageHandler do
  alias ProtohackerElixir.Speed.SerializableUtils
  alias ProtohackerElixir.Speed.DataType.IAmDispatcher
  alias ProtohackerElixir.Speed.DataType.IAmCamera
  alias ProtohackerElixir.Speed.DataType.WantHeartbeat
  alias ProtohackerElixir.Speed.ClientInfo
  require Logger

  def process_client_msg(%ClientInfo{socket: socket}, %WantHeartbeat{interval: interval} = msg) do
    :gen_tcp.send(socket, SerializableUtils.serialize(msg))
  end

  @spec process_client_msg(ClientInfo.t(), IAmCamera.t()) :: :ok | :error
  def process_client_msg(%ClientInfo{role: role}, %IAmCamera{} = msg) do
    case role do
      :camera ->
        :ok

      _ ->
        :error
    end
  end

  @spec process_client_msg(ClientInfo.t(), IAmDispatcher.t()) :: :ok
  def process_client_msg(%ClientInfo{}, %IAmDispatcher{} = msg) do
    :ok
  end

  @spec process_client_msg(ClientInfo.t(), any()) :: :ok
  def process_client_msg(%ClientInfo{}, msg) do
    Logger.debug("unexpected msg #{inspect(msg)}")
  end
end
