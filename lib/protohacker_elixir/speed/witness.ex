defmodule ProtohackerElixir.Speed.Witness do
  defstruct [:plate, :mile1, :timestamp1, :mile2, :timestamp2]

  @type t :: %__MODULE__{
          plate: String.t(),
          mile1: integer(),
          timestamp1: integer(),
          mile2: integer(),
          timestamp2: integer()
        }
end
