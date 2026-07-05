defmodule ProtohackerElixir.Speed.Database.TicketDbServer do
  alias ProtohackerElixir.Speed.Database.TicketDbServer.Ticket
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    :ets.new(:ticket, [:duplicate_bag, :public, :named_table, read_concurrency: true])
  end

  # 保存生成过的罚单
  @spec insert_ticket(Ticket.t()) :: integer()
  def insert_ticket(ticket) do
    GenServer.call(__MODULE__, {:insert_ticket, ticket})
  end

  # 查询某路段的罚单
  @spec query_ticket_by_road(integer()) :: [Ticket.t()]
  def query_ticket_by_road(road) do
    GenServer.call(__MODULE__, {:query_ticket, road})
  end

  def handle_call(
        {:insert_ticket,
         %Ticket{
           plate: plate,
           road: road,
           mile1: mile1,
           mile2: mile2,
           timestamp1: timestamp1,
           timestamp2: timestamp2,
           speed: speed
         }},
        _from,
        state
      ) do
    :ets.insert(
      :ticket,
      {plate, road, mile1, mile2, timestamp1, timestamp2, speed, false,
       :crypto.strong_rand_bytes(16)}
    )

    {:reply, {:ok}, state}
  end

  def handle_call({:query_ticket, road}, _from, state) do
    tickets =
      :ets.match_object(:ticket, {:_, road, :_, :_, :_, :_, :_, :_})
      |> Enum.map(fn {plate, road, mile1, mile2, timestamp1, timestamp2, speed, is_issued, id} ->
        %Ticket{
          plate: plate,
          road: road,
          mile1: mile1,
          mile2: mile2,
          timestamp1: timestamp1,
          timestamp2: timestamp2,
          speed: speed,
          is_issued: is_issued,
          id: id
        }
      end)

    {:reply, tickets, state}
  end
end
