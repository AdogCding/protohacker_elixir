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

  @spec insert_witness(CameraRecord.t())
  def insert_witness(witness) do
  end
end
