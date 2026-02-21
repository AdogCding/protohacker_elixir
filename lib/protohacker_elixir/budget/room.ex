defmodule ProtohackerElixir.Budget.Room do
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args)
  end

  @impl true
  def init(init_arg) do
  end
end
