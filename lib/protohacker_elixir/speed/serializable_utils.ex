defmodule ProtohackerElixir.Speed.SerializableUtils do
  alias ProtohackerElixir.Speed.Serializable

  @spec serialize(Serializable.t()) :: binary()
  def serialize(data) do
    Serializable.encode(data)
  end
end
