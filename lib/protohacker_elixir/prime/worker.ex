defmodule ProtohackerElixir.Prime.Worker do
  @behaviour ProtohackerElixir.Generic.Challenge

  def handle_connection(socket) do
    :gen_tcp.send(socket, "I love you")
  end
end
