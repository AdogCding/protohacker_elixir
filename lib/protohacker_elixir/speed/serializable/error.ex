alias ProtohackerElixir.Speed.Serializable
alias ProtohackerElixir.Speed.DataType.Error

defimpl Serializable, for: Error do
  def encode(%Error{msg: msg}) do
    msg_bin = Serializable.Helper.encode_str(msg)
    <<0x22, msg_bin::binary>>
  end
end
