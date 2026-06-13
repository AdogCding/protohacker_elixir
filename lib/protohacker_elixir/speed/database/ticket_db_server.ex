defmodule ProtohackerElixir.Speed.Database.TicketDbServer do
  alias ProtohackerElixir.Speed.Database.Ticket
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    :ets.new(:ticket, [:duplicate_bag, :public, :named_table, read_concurrency: true])
  end

  # 保存生成过的罚单
  @spec insert_ticket(Ticket.t()) :: integer()
  def insert_ticket(ticket) do
    GenServer.call(__MODULE__, {:insert_ticket, ticket})
  end

  # 查询某牌某日是否有罚单
  @spec query_ticket(String.t(), integer()) :: [Ticket.t()]
  def query_ticket(plate, day) do
    GenServer.call(__MODULE__, {:query_ticket, {plate, day}})
  end

  def handle_call(
        {:insert_ticket,
         %Ticket{
           plate: plate,
           road: road,
           mile1: mile1,
           mile2: mile2,
           timestamp1: timestamp1,
           timestamp2: timestamp2
         }},
        _from,
        state
      ) do
    :ets.insert(
      :ticket,
      {plate, road, mile1, mile2, timestamp1, timestamp2, false, :crypto.strong_rand_bytes(16)}
    )

    {:reply, {:ok}, state}
  end
end
