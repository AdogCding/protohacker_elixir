defmodule ProtohackerElixir.Echo.Worker do
  require Logger

  def start_link(socket) do
    receive do
      :socket_transferred ->
        main_loop(socket)
    end
  end

  def main_loop(client_socket) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, line} ->
        Logger.debug("Receive a line: #{line}")
        :gen_tcp.send(client_socket, line)
        main_loop(client_socket)

      {:error, reason} ->
        Logger.debug("Error: #{reason}")
        {:error, reason}
    end
  end
end
