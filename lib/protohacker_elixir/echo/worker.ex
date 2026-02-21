defmodule ProtohackerElixir.Echo.Worker do
  use ProtohackerElixir.Generic.SimpleChallenge

  @impl true
  def main_loop(client_socket, state) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, line} ->
        :gen_tcp.send(client_socket, line)
        main_loop(client_socket, state)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
