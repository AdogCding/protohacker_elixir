defmodule ProtohackerElixir.Budget.Client do
  @behaviour :gen_statem
  require Logger

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(state) do
    :gen_statem.start_link(__MODULE__, state, [])
  end

  def child_spec(args) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [args]},
      restart: :transient
    }
  end

  def callback_mode do
    [:handle_event_function, :state_enter]
  end

  def init(args) do
    {:ok, :awaiting_name, args}
  end

  def handle_event(:enter, oldState, :awaiting_name, data) do
    Logger.debug("Client handle_event :enter: #{inspect(oldState)}, #{inspect(data)}")
    {:keep_state_and_data, []}
  end

  def handle_event(:enter, oldState, :ready, data) do
    Logger.debug("Client handle_event :enter: #{inspect(oldState)}, #{inspect(data)}")
    %{client_socket: client_socket} = data

    case :gen_tcp.recv(client_socket, 0) do
      {:ok, data} ->
        :gen_tcp.send(client_socket, "Welcome to budgetchat! What shall I call you?")

      {:error, reason} ->
        Logger.error("Error receiving data from client: #{inspect(reason)}")
        :gen_tcp.close(client_socket)
    end

    {:keep_state_and_data, []}
  end

  def handle_event(:info, :socket_transferred, _currentState, data) do
    Logger.debug("Client handle_event :info: :socket_transferred, #{inspect(data)}")
    {:next_state, :ready, data}
  end

  def handle_event(:info, info, currentState, data) do
    Logger.debug(
      "Client handle_event :info: #{inspect(info)}, #{inspect(currentState)}, #{inspect(data)}"
    )

    {:keep_state_and_data, []}
  end
end
