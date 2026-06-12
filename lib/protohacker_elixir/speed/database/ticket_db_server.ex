defmodule ProtohackerElixir.Speed.Database.TicketDbServer do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(args) do
    :ets.new(:ticket, [:duplicate_bag, :public, :named_table, read_concurrency: true])
  end
end
