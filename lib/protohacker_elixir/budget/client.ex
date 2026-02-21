defmodule ProtohackerElixir.Budget.Client do
  @behaviour :gen_statem

  def start_link(state) do
    :gen_statem.start_link(__MODULE__, state, [])
  end

  def callback_mode do
    :handle_event_function
  end

  def init(args = %{client_socket: client_socket}) do
    :gen_tcp.send(client_socket, "I am started: #{inspect(args)}")
  end
end
