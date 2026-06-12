defmodule ProtohackerElixir.Speed.Database do
  alias ProtohackerElixir.Speed.Database.Road
  alias ProtohackerElixir.Speed.DataType.Ticket
  alias ProtohackerElixir.Speed.Database.IssuedTicketRecord
  alias ProtohackerElixir.Speed.Database.CameraRecord

  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    :ets.new(:camera_record, [:duplicate_bag, :public, :named_table, read_concurrency: true])
    :ets.new(:ticket, [:duplicate_bag, :public, :named_table, read_concurrency: true])
    :ets.new(:road, [:set, :public, :named_table, read_concurrency: true])
    :ets.new(:issued_ticket_record, [:set, :public, :named_table, read_concurrency: true])
    {:ok, %{}}
  end

  # 保存摄像头的拍摄记录
  @spec insert_camera_record(CameraRecord.t()) :: {:ok} | {:error}
  def insert_camera_record(camera_record) do
    GenServer.call(__MODULE__, {:insert_camera_record, camera_record})
  end

  @spec query_camera_record(String.t(), integer()) :: [CameraRecord.t()]
  def query_camera_record(plate, road) do
    GenServer.call(__MODULE__, {:query_camera_record, {plate, road}})
  end

  # 保存处罚过的罚单
  @spec insert_issued_ticket_record(IssuedTicketRecord.t()) :: {:ok} | {:error}
  def insert_issued_ticket_record(issued_ticket_record) do
    GenServer.call(__MODULE__, {:insert_issued_ticket_record, issued_ticket_record})
  end

  # 保存生成过的罚单
  @spec insert_ticket(Ticket.t()) :: {:ok} | {:error}
  def insert_ticket(ticket) do
    GenServer.call(__MODULE__, {:insert_ticket, ticket})
  end

  # 查询某牌某日是否有罚单
  @spec query_ticket(String.t(), integer()) :: Ticket.t()
  def query_ticket(plate, day) do
    GenServer.call(__MODULE__, {:query_ticket, {plate, day}})
  end

  # 保存道路的信息
  @spec insert_road(Road.t()) :: {:ok} | {:error}
  def insert_road(road) do
    GenServer.call(__MODULE__, {:insert_road, road})
  end

  # 查询道路信息
  @spec query_road(integer()) :: Road.t()
  def query_road(road) do
  end

  def handle_call(
        {:insert_camera_record,
         %CameraRecord{plate: plate, road: road, mile: mile, timestamp: timestamp}},
        _from,
        state
      ) do
    :ets.insert(:camera_record, {plate, road, mile, timestamp})
    {:reply, {:ok}, state}
  end

  def handle_call({:query_camera_record, {plate, road}}, _from, state) do
    camera_records = :ets.match_object(:camera_record, {plate, road, :_, :_})
    {:reply, camera_records |> Enum.map(&CameraRecord.new(&1)), state}
  end

  def handle_call({:insert_road, %Road{road: road, limit: limit}}, _from, state) do
    :ets.insert_new(:road, {road, limit})
    {:reply, {:ok}, state}
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
