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

  # 保存道路的信息
  @spec insert_road(Road.t()) :: {:ok} | {:error}
  def insert_road(road) do
    GenServer.call(__MODULE__, {:insert_road, road})
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
end
