defmodule ProtohackerElixir.Speed.DataType.Error do
  alias ProtohackerElixir.Speed.Message
  @behaviour Message
  defstruct msg: nil

  @type t :: %__MODULE__{
          msg: String.t()
        }

  @impl true
  def new(<<msg_len::unsigned-8-big, msg::binary-size(msg_len), rest::binary>>) do
    {:ok, %__MODULE__{msg: msg}, rest}
  end

  @impl true
  def new(_) do
    {:error, :imcomplete}
  end
end
