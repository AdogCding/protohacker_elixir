defmodule ProtohackerElixir.Speed.TicketHelper do
  alias ProtohackerElixir.Speed.SpeedLimitHelper
  alias ProtohackerElixir.Speed.Serializable
  alias ProtohackerElixir.Speed.Client
  alias ProtohackerElixir.Speed.Database.IssuedTicketDbServer
  alias ProtohackerElixir.Speed.Database.TicketDbServer
  alias ProtohackerElixir.Speed.DataType

  @spec issuable?(ProtohackerElixir.Speed.Database.TicketDbServer.Ticket.t()) :: boolean()
  def issuable?(ticket) do
    %TicketDbServer.Ticket{
      plate: plate,
      timestamp1: timestamp1,
      timestamp2: timestamp2
    } = ticket

    days = SpeedLimitHelper.caculate_days(timestamp1, timestamp2)

    days
    |> Enum.filter(fn day ->
      IssuedTicketDbServer.query_issued_ticket(%{plate: plate, day: day}) |> Enum.empty?()
    end)
    |> Enum.empty?()
  end
end
