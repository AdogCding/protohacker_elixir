defmodule ProtohackerElixir.Speed.DataType.Ticket do
  defstruct plate: nil,
            road: nil,
            mile1: nil,
            timestamp1: nil,
            mile2: nil,
            timestamp2: nil,
            speed: nil

  @type t :: %__MODULE__{
          plate: String.t(),
          road: number(),
          mile1: number(),
          timestamp1: number(),
          mile2: number(),
          timestamp2: number(),
          speed: number()
        }
end
