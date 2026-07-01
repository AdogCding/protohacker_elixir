defmodule ProtohackerElixir.Speed.Database.RoadDbServer do
  alias ProtohackerElixir.Speed.Database.RoadDbServer.Road
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(_) do
    table = :ets.new(:road, [:set, :public, :named_table, read_concurrency: true])

    {:ok, %{table: table}}
  end

  # 保存道路的信息
  @spec insert_road(Road.t()) :: {:ok} | {:error}
  def insert_road(road) do
    GenServer.call(__MODULE__, {:insert_road, road})
  end

  # 查询道路信息
  @spec query_road(integer()) :: Road.t()
  def query_road(road) do
    GenServer.call(__MODULE__, {:query_road, road})
  end

  def handle_call({:insert_road, %Road{road: road, limit: limit}}, _from, state) do
    :ets.insert_new(:road, {road, limit})
    {:reply, {:ok}, state}
  end

  def handle_call({:query_road, road}, _from, state) do
    road = :ets.lookup(:road, road)
    {:reply, road, state}
  end
end
