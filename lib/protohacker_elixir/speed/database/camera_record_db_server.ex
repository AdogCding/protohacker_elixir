defmodule ProtohackerElixir.Speed.Database.CameraRecordDbServer do
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer.CameraRecord
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    table =
      :ets.new(:camera_record, [:duplicate_bag, :public, :named_table, read_concurrency: true])

    {:ok, %{table: table}}
  end

  # 保存摄像头的拍摄记录
  @spec insert_camera_record(CameraRecord.t()) :: {:ok} | {:error}
  def insert_camera_record(camera_record) do
    GenServer.call(__MODULE__, {:insert_camera_record, camera_record})
  end

  # 查询摄像头拍摄记录
  @spec query_camera_record(String.t(), integer()) :: [CameraRecord.t()]
  def query_camera_record(plate, road) do
    GenServer.call(__MODULE__, {:query_camera_record, {plate, road}})
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
end
