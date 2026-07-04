defmodule ProtohackerElixir.Speed.TicketHelper do
  alias ProtohackerElixir.Speed.SpeedLimitHelper
  alias ProtohackerElixir.Speed.Serializable
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

  @spec send_ticket(port(), ProtohackerElixir.Speed.Database.TicketDbServer.Ticket.t()) :: :ok
  def send_ticket(socket, %TicketDbServer.Ticket{
        plate: plate,
        road: road,
        mile1: mile1,
        mile2: mile2,
        timestamp1: timestamp1,
        timestamp2: timestamp2,
        speed: speed
      }) do
    # 转成报文的数据格式
    tk = %DataType.Ticket{
      plate: plate,
      timestamp1: timestamp1,
      timestamp2: timestamp2,
      road: road,
      mile1: mile1,
      mile2: mile2,
      speed: speed
    }

    :gen_tcp.send(socket, Serializable.Helper.serialize(tk))
    # 发送完毕后，记录到已发送的罚单数据库中
    
  end
end
