defmodule ProtohackerElixir.Speed.Database.TicketDbServer.Ticket do
  defstruct [:plate, :road, :mile1, :mile2, :timestamp1, :timestamp2, :issued?, :id]

  @type t :: %__MODULE__{
          plate: String.t(),
          road: integer(),
          mile1: integer(),
          mile2: integer(),
          timestamp1: integer(),
          timestamp2: integer(),
          issued?: boolean(),
          id: String.t()
        }
end
