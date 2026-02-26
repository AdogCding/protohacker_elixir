defmodule ProtohackerElixir.StrangeDb.DbServer do
  alias ProtohackerElixir.StrangeDb.DbState
  use GenServer
  require Logger

  def start_link(opts) do
    version = Keyword.get(opts, :version)
    GenServer.start_link(__MODULE__, %{version: version}, name: __MODULE__)
  end

  def init(init_arg) do
    {:ok, %DbState{data: %{"version" => init_arg.version}}}
  end

  def insert(key, value) do
    GenServer.cast(__MODULE__, {:insert, key, value})
  end

  def handle_cast({:insert, key, value}, state) do
    updated_data = Map.put(state.data, key, value)
    {:noreply, %{state | data: updated_data}}
  end

  def retrieve(key) do
    GenServer.call(__MODULE__, {:retrieve, key})
  end

  def handle_call({:retrieve, key}, from, state) do
    {:reply, Map.get(state.data, key), state}
  end
end
