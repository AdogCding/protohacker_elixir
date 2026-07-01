defmodule ProtohackerElixir.Speed.TicketManager do
  # 负责罚单的产生
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: ProtohackerElixir.Speed.TicketManager)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  @spec try_generate_ticket(integer()) :: :ok
  def try_generate_ticket(road) do
    GenServer.cast(ProtohackerElixir.Speed.TicketManager, {:try_generate_ticket, road})
  end

  def handle_cast({:try_generate_ticket, road}, state) do
    # 这里可以根据实际需求来决定是否生成罚单
    {:noreply, state}
  end
end
