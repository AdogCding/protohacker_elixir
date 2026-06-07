alias ProtohackerElixir.Speed.Serializable
alias ProtohackerElixir.Speed.DataType.Ticket

defimpl Serializable, for: Ticket do
  def encode(%Ticket{plate: plate_str}) do
    plate_bin = Serializable.Helper.encode_str(plate_str)
    <<0x21, plate_bin::binary>>
  end
end
