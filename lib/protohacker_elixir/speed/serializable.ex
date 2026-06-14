defprotocol ProtohackerElixir.Speed.Serializable do
  alias ProtohackerElixir.Speed.Serializable
  @type t :: term()

  @spec encode(message :: Serializable.t()) :: binary()
  def encode(message)
end
