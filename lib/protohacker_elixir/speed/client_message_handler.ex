defmodule ProtohackerElixir.Speed.ClientMessageHandler do
  def process_client_msg(%WantHeartbeat{interval: interval}) do
    send(self(), {:setup_hearbeat_interval, interval})
  end

  def process_client_msg(%IAmCamera{}) do
  end

  defp process_client_msg(%IAmDispatcher{}) do
  end

  defp process_client_msg(msg) do
    Logger.debug("unexpect msg #{msg}")
  end
end
