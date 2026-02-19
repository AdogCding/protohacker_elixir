defmodule ProtohackerElixir.Echo.Worker do
  use ProtohackerElixir.Generic.Challenge

  @impl true
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
