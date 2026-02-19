defmodule ProtohackerElixir.Echo.Worker do
  def start_link(socket) do

  end

  def work(client_socket) do
    IO.puts("I am echo worker")
  end
end
