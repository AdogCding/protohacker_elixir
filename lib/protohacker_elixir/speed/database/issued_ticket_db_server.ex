defmodule ProtohackerElixir.Speed.Database.IssuedTicketDbServer do
  alias ProtohackerElixir.Speed.Database.IssuedTicketDbServer.IssuedTicketRecord

  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [])
  end

  def init(_) do
    :ets.new(:issued_ticket_record, [:set, :public, :named_table, read_concurrency: true])
    {:ok, %{}}
  end

  # 保存处罚过的罚单
  @spec insert_issued_ticket_record(IssuedTicketRecord.t()) :: {:ok} | {:error}
  def insert_issued_ticket_record(issued_ticket_record) do
    GenServer.call(__MODULE__, {:insert_issued_ticket_record, issued_ticket_record})
  end

  def handle_call(
        {:insert_issued_ticket_record,
         %IssuedTicketRecord{plate: plate, day: day, ticket_id: ticket_id}},
        _from,
        state
      ) do
    res =
      case :ets.insert_new(:issued_ticket_record, {{plate, day}, ticket_id}) do
        true -> {:ok}
        _ -> {:error}
      end

    {:reply, res, state}
  end
end
