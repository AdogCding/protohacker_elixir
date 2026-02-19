defmodule ProtohackerElixir.Echo.Worker do
  def start_link(socket) do
  end

  def main_loop(client_socket) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, line} -> IO.puts(line)
      {:error, reason} -> {:error, reason}
    end
  end
end
