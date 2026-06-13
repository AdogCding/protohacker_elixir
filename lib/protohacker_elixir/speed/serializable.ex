defprotocol ProtohackerElixir.Speed.Serializable do
  @type t :: term()

  @spec encode(message :: struct()) :: binary()
  def encode(message)
end
