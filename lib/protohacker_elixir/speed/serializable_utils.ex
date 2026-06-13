defmodule ProtohackerElixir.Speed.SerializableUtils do
  alias ProtohackerElixir.Speed.Serializable

  @spec send_data(:gen_tcp.socket(), Serializable.t()) :: :ok | {:error, any()}
  def send_data(socket, data) do
    :gen_tcp.send(socket, Serializable.encode(data))
  end
end
