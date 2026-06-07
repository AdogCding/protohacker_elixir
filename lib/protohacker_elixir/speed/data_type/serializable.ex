defprotocol ProtohackerElixir.Speed.DataType.Serializable do
  @spec encode(message :: struct()) :: binary()
  def encode(message)
end
