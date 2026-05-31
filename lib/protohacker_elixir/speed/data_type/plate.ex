defmodule ProtohackerElixir.Speed.DataType.Plate do
  defstruct plate: nil, timestamp: nil

  @type t :: %__MODULE__{
          plate: String.t(),
          timestamp: number()
        }
end
