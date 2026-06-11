defmodule ProtohackerElixir.Speed.Database.Road do
  defstruct [:road, :limit]

  @type t :: %__MODULE__{
          road: integer(),
          limit: integer()
        }
end
