defmodule ProtohackerElixir.Proxy.Client do
  require Logger
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(args) do
    Logger.debug("Init args: #{inspect(args)}")

    {:ok,
     args
     |> Map.put(:target_addr, "chat.protohackers.com")
     |> Map.put(:target_port, 16963)
     |> Map.put(:tony_boguscoin_addr, "7YWHMfk9JZe0LM0g1ZauHuiSxhI")}
  end

  def handle_info(:socket_transferred, state) do
    Logger.debug("Process active:#{inspect(state)}")
    %{target_addr: target_addr, target_port: target_port} = state
    # connect to real server
    {:ok, socket} =
      :gen_tcp.connect(String.to_charlist(target_addr), target_port, [:binary, active: :once])

    # make client socket active
    :inet.setopts(state.client_socket, active: :once)
    {:noreply, Map.put(state, :server_socket, socket)}
  end

  def handle_info({:tcp, socket, data}, state) do
    %{client_socket: client_socket, server_socket: server_socket} = state

    case socket do
      ^client_socket ->
        client_msg = handle_client_data(data, state)
        :gen_tcp.send(server_socket, client_msg)

      ^server_socket ->
        handle_server_data(data, state)
        :gen_tcp.send(client_socket, data)
    end

    :inet.setopts(socket, active: :once)
    {:noreply, state}
  end

  def handle_info({:tcp_closed, _socket}, state) do
    {:stop, :normal, state}
  end

  def terminate(reason, _state) do
    Logger.debug("Process terminate for #{reason}")
  end

  defp handle_client_data(data, state) do
    Logger.debug("Receive client data: #{inspect(data)}, State: #{inspect(state)}")
    %{tony_boguscoin_addr: tony_boguscoin_addr} = state

    data
    |> ProtohackerElixir.Proxy.Helper.replace_boguscoin_address(tony_boguscoin_addr)
  end

  defp handle_server_data(data, state) do
    Logger.debug("Receive server data: #{inspect(data)}, State: #{inspect(state)}")
    data
  end
end
