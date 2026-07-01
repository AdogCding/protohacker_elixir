defmodule ProtohackerElixir.Speed.Database.IssuedTicketDbServer.IssuedTicketRecord do
  # 存储发送过的罚单
  defstruct [:plate, :day, :ticket_id]

  @type t :: %__MODULE__{
          plate: String.t(),
          day: integer(),
          ticket_id: String.t()
        }
end
