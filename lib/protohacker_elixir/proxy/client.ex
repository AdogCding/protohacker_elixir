defmodule ProtohackerElixir.Proxy.Client do
  require Logger
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(args) do
    {:ok, args}
  end

  def handle_info(:socket_transferred, state) do
    Logger.debug("Process active:#{inspect(state)}")
    :inet.setopts(state.client_socket, active: :once)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, state) do
    Logger.debug("Receive data: #{inspect(data)}, State: #{inspect(state)}")
    {:noreply, state}
  end
end
