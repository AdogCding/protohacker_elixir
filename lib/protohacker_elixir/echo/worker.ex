defmodule ProtohackerElixir.Echo.Worker do
  @behaviour ProtohackerElixir.Generic.Challenge
  require Logger

  @impl true
  def handle_connection(socket) do
    start_link(socket)
  end

  def start_link(socket) do
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
        {:error, reason}
    end
  end
end
