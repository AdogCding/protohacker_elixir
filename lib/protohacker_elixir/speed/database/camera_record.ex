defmodule ProtohackerElixir.Speed.Database.CameraRecord do
  defstruct [:plate, :road, :mile, :timestamp]

  @type t :: %__MODULE__{
          plate: String.t(),
          road: integer(),
          mile: integer(),
          timestamp: integer()
        }
end
