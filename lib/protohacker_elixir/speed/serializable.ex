defprotocol ProtohackerElixir.Speed.Serializable do
  @spec encode(message :: struct()) :: binary()
  def encode(message)
end
