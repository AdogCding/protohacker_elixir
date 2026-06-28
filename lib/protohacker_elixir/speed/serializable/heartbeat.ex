alias ProtohackerElixir.Speed.Serializable
alias ProtohackerElixir.Speed.DataType.Heartbeat

defimpl Serializable, for: Heartbeat do
  def encode(%Heartbeat{}) do
    <<0x41>>
  end
end
