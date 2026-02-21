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
    {:ok, :await_socket_transferred, args}
  end

  def handle_event(:enter, _oldState, :await_socket_transferred, _data) do
    Logger.debug("Client is awaiting socket transferred")
    {:keep_state_and_data, []}
  end

  def handle_event(:internal, :send_welcome_and_await_name, :ready, data) do
    %{client_socket: client_socket} = data
    :gen_tcp.send(client_socket, "Welcome to budgetchat! What shall I call you?")
    {:next_state, :awaiting_name, data, [{:next_event, :internal, :await_name}]}
  end

  def handle_event(
        :internal,
        :await_name,
        :awaiting_name,
        state = %{client_socket: client_socket}
      ) do
    case :gen_tcp.recv(client_socket, 0) do
      {:ok, data} ->
        name = data |> String.trim()

        if(String.length(name) <= 0) do
          {:next_state, :killed, state, [{:next_event, :internal, :kill}]}
        else
          {:next_state, :joined, Map.put(state, :name, name),
           [{:next_event, :internal, :broadcast_my_join}]}
        end

      {:error, reason} ->
        Logger.error("Error receiving data from client: #{inspect(reason)}")
        {:next_state, :killed, state, [{:next_event, :internal, :kill}]}
    end
  end

  def handle_event(:internal, :join, :joined, state) do
    %{client_socket: client_socket} = state

    case :gen_tcp.recv(client_socket, 0) do
      {:ok, data} ->
        Logger.debug("Received data from client: #{inspect(data)}")
        {:keep_state_and_data, []}

      {:error, reason} ->
        Logger.error("Error receiving data from client: #{inspect(reason)}")
        {:next_state, :killed, state, [{:next_event, :internal, :kill}]}
    end
  end

  def handle_event(:internal, :kill, :killed, data) do
    Logger.debug("Client is going to be killed")
    %{client_socket: client_socket} = data
    :gen_tcp.close(client_socket)
    {:stop, :normal, data}
  end

  def handle_event(:info, :socket_transferred, _currentState, data) do
    Logger.debug("Client handle_event :info: :socket_transferred, #{inspect(data)}")
    {:next_state, :ready, data, [{:next_event, :internal, :send_welcome_and_await_name}]}
  end

  def handle_event(:info, info, currentState, data) do
    Logger.debug(
      "Client handle_event :info: #{inspect(info)}, #{inspect(currentState)}, #{inspect(data)}"
    )

    {:keep_state_and_data, []}
  end

  def handle_event(:enter, oldState, currentState, data) do
    Logger.debug(
      "Client entering state #{inspect(currentState)} from #{inspect(oldState)} with data #{inspect(data)}"
    )

    {:keep_state_and_data, []}
  end
end
