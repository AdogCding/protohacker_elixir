defmodule ProtohackerElixir.Speed.DataType.WantHeartbeat do
  defstruct interval: nil

  @type t :: %__MODULE__{
          interval: number()
        }
end
