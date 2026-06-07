defmodule ProtohackerElixir.Speed.DataType.Error do
  alias ProtohackerElixir.Speed.Message
  alias ProtohackerElixir.Speed.DataType.Serializable
  @behaviour Message
  defstruct msg: nil

  @type t :: %__MODULE__{
          msg: String.t()
        }

  @impl true
  def new(<<msg_len::unsigned-8, msg::binary-size(msg_len), rest::binary>>) do
    {:ok, %__MODULE__{msg: msg}, rest}
  end

  @impl true
  def new(_) do
    {:error, :not_match}
  end

  defimpl Serializable, for: __MODULE__ do
    def encode(error) do
      msg = error.msg
      msg_len = String.length(msg)
      <<0x20, msg_len::unsigned-8, msg::binary-size(msg_len)>>
    end
  end
end
