defmodule ProtohackerElixir.Speed.Serializable.Helper do
  def encode_str(msg) when length(msg) > 255 do
    raise RuntimeError, message: "#{msg} exceed 255 size"
  end

  @spec encode_str(String.t()) :: binary()
  def encode_str(message) do
    size_of_msg = byte_size(message)
    <<size_of_msg::unsigned-8, message::binary>>
  end
end
