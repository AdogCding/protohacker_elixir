defmodule ProtohackerElixir.Speed.ClientMessageHandler do
  def process_client_msg(pid, %WantHeartbeat{interval: interval}) do
    send(pid, {:setup_hearbeat_interval, interval})
  end

  def process_client_msg(pid, %IAmCamera{}) do
    send(pid, {:i_am_camera})
  end

  defp process_client_msg(pid, %IAmDispatcher{}) do
    send(pid, {:i_am_dispatcher})
  end

  defp process_client_msg(msg) do
    Logger.debug("unexpect msg #{msg}")
  end
end
