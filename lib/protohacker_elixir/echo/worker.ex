defmodule ProtohackerElixir.Echo.Worker do
  require Logger

  def start_link(socket) do
    Logger.debug("Start worker")

    receive do
      :socket_transferred ->
        main_loop(socket)

      error ->
        Logger.debug("Starting, unexpected message:#{error}")
    end
  end

  def main_loop(client_socket) do
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
