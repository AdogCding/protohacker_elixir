defmodule ProtohackerElixir.Speed.DataType.IAmDispatcher do
  defstruct numroads: nil, road: []

  @type t :: %__MODULE__{
          numroads: number(),
          road: list(number())
        }
end
