defmodule ProtohackerElixir.Speed.Database do
  alias ProtohackerElixir.Speed.Database.CameraRecord

  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_args) do
    :ets.new(:witness, [:duplicate_bag, :public, :named_table, read_concurrency: true])
    {:ok, %{}}
  end

  # 保存摄像头的拍摄记录
  @spec insert_camera_record(CameraRecord.t()) :: {:ok}
  def insert_camera_record(camera_record) do
    GenServer.call(__MODULE__, {:insert_camera_record, camera_record})
  end

  # 保存开出的罚单
  def insert_ticket() do
  end

  def handle_call(
        {:insert_camera_record,
         %CameraRecord{plate: plate, road: road, mile: mile, timestamp: timestamp}},
        _from,
        state
      ) do
    :ets.insert(:witness, {plate, road, mile, timestamp})
    {:reply, {:ok}, state}
  end
end
