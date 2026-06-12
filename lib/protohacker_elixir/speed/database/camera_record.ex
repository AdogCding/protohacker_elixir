defmodule ProtohackerElixir.Speed.Database.CameraRecord do
  defstruct [:plate, :road, :mile, :timestamp]

  @type t :: %__MODULE__{
          plate: String.t(),
          road: integer(),
          mile: integer(),
          timestamp: integer()
        }
  def new({plate, road, mile, timestamp}) do
    %__MODULE__{
      plate: plate,
      road: road,
      mile: mile,
      timestamp: timestamp
    }
  end
end
