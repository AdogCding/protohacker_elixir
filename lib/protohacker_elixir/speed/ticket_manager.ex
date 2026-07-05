defmodule ProtohackerElixir.Speed.TicketManager do
  alias ProtohackerElixir.Speed.TicketHelper
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer.CameraRecord
  alias ProtohackerElixir.Speed.TicketManager.Generator
  alias ProtohackerElixir.Speed.Client
  alias ProtohackerElixir.Speed.DataType
  alias ProtohackerElixir.Speed.Database.TicketDbServer
  # 负责罚单的产生
  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: ProtohackerElixir.Speed.TicketManager)
  end

  def init(init_arg) do
    {:ok, init_arg}
  end

  @spec try_generate_ticket(CameraRecord.t()) :: :ok
  def try_generate_ticket(camera_record) do
    GenServer.cast(ProtohackerElixir.Speed.TicketManager, {:try_generate_ticket, camera_record})
  end

  def handle_cast({:try_generate_ticket, camera_record}, state) do
    # 这里可以根据实际需求来决定是否生成罚单
    tickets = Generator.try_generate_ticket(camera_record)
    for tk <- tickets, TicketHelper.issuable?(tk), do: send_ticket(tk)
    {:noreply, state}
  end

  @spec send_ticket(ProtohackerElixir.Speed.Database.TicketDbServer.Ticket.t()) ::
          :ok
  defp send_ticket(%TicketDbServer.Ticket{
         plate: plate,
         road: road,
         mile1: mile1,
         mile2: mile2,
         timestamp1: timestamp1,
         timestamp2: timestamp2,
         speed: speed
       }) do
    # 转成报文的数据格式
    tk = %DataType.Ticket{
      plate: plate,
      timestamp1: timestamp1,
      timestamp2: timestamp2,
      road: road,
      mile1: mile1,
      mile2: mile2,
      speed: speed
    }

    Registry.dispatch(ProtohackerElixir.Speed.DispatcherRegistry, road, fn entries ->
      for {pid, _} <- entries do
        Client.issue_ticket(pid, tk)
      end
    end)

    # 发送完毕后，记录到已发送的罚单数据库中
  end
end
