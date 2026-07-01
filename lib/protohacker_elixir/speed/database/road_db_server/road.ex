defmodule ProtohackerElixir.Speed.Database.RoadDbServer.Road do
  defstruct [:road, :limit]

  @type t :: %__MODULE__{
          road: integer(),
          limit: integer()
        }
end
