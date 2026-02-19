defmodule ProtohackerElixir.Echo.Worker do
  require Logger

  def start_link(socket) do
    Logger.debug("Start work")

    receive do
      :socket_transferred ->
        main_loop(socket)
    end
  end

  def main_loop(client_socket) do
    Logger.debug("Start loop")

    case :gen_tcp.recv(client_socket, 0) do
      {:ok, line} ->
        :gen_tcp.send(client_socket, line)
        main_loop(client_socket)

      {:error, reason} ->
        Logger.debug("Error: #{reason}")
        {:error, reason}
    end
  end
end
