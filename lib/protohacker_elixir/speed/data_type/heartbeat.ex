defmodule ProtohackerElixir.Speed.DataType.Heartbeat do
  defstruct road: nil, mile: nil, limit: nil

  @type t :: %__MODULE__{
          road: number(),
          mile: number(),
          limit: number()
        }
end
