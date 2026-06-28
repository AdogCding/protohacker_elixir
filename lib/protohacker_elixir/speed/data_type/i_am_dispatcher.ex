defmodule ProtohackerElixir.Speed.DataType.IAmDispatcher do
  alias ProtohackerElixir.Speed.Message
  defstruct numroads: nil, roads: []
  @behaviour Message

  @type t :: %__MODULE__{
          numroads: number(),
          roads: list(number())
        }
  def new(<<list_size::unsigned-8, elements::binary-size(list_size), rest::binary>>) do
    {:ok, %__MODULE__{numroads: list_size, roads: :erlang.binary_to_list(elements)}, rest}
  end

  def new(_) do
    {:error, :incomplete}
  end
end
