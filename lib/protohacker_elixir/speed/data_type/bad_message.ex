defmodule ProtohackerElixir.Speed.DataType.BadMessage do
  alias ProtohackerElixir.Speed.Message
  defstruct bad_msg: <<>>
  @behaviour Message

  def new(bytes) do
    %__MODULE__{
      bad_msg: bytes
    }
  end
end
