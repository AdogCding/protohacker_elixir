defmodule ProtohackerElixir.Speed.Database.TicketDbServer.Ticket do
  @enforce_keys [:plate, :road, :mile1, :mile2, :timestamp1, :timestamp2, :is_issued, :speed, :id]
  defstruct [:plate, :road, :mile1, :mile2, :timestamp1, :timestamp2, :is_issued, :speed, :id]

  @type t :: %__MODULE__{
          plate: String.t(),
          road: integer(),
          mile1: integer(),
          mile2: integer(),
          timestamp1: integer(),
          timestamp2: integer(),
          is_issued: boolean(),
          speed: integer(),
          id: String.t()
        }
end
