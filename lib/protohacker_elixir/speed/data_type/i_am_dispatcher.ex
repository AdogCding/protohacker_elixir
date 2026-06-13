defmodule ProtohackerElixir.Speed.DataType.IAmDispatcher do
  alias ProtohackerElixir.Speed.Message
  defstruct numroads: nil, road: []
  @behaviour Message

  @type t :: %__MODULE__{
          numroads: number(),
          road: list(number())
        }
  def new(<<list_size::unsigned-8, elements::binary-size(list_size), rest::binary>>) do
    {:ok, %__MODULE__{numroads: list_size, road: :erlang.binary_to_list(elements)}, rest}
  end

  def new(_) do
    {:error, :incomplete}
  end
end
