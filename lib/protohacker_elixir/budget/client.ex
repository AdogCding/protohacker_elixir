defmodule ProtohackerElixir.Budget.Client do
  @behaviour :gen_statem
  require Logger

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(state) do
    :gen_statem.start_link(__MODULE__, state, [])
  end

  def child_spec(args) do
    Logger.debug("Client child_spec: #{inspect(args)}")

    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      restart: :transient
    }
  end

  def callback_mode do
    :handle_event_function
  end

  def init(args = %{client_socket: client_socket}) do
    :gen_tcp.send(client_socket, "I am started: #{inspect(args)}")
  end
end
