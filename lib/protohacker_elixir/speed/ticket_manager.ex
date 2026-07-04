defmodule ProtohackerElixir.Speed.TicketManager do
  alias ProtohackerElixir.Speed.TicketManager.Generator
  alias ProtohackerElixir.Speed.Client
  # 负责罚单的产生
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: ProtohackerElixir.Speed.TicketManager)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  @spec try_generate_ticket(String.t(), integer()) :: :ok
  def try_generate_ticket(plate, road) do
    GenServer.cast(ProtohackerElixir.Speed.TicketManager, {:try_generate_ticket, {plate, road}})
  end

  def handle_cast({:try_generate_ticket, {plate, road}}, state) do
    # 这里可以根据实际需求来决定是否生成罚单
    tickets = Generator.try_generate_ticket(plate, road)
    Client.issue_ticket(tickets)
    {:noreply, state}
  end
end
