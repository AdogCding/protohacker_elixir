defmodule ProtohackerElixir.Budget.Client do
  @moduledoc false
  alias ProtohackerElixir.Budget.Message
  alias ProtohackerElixir.Generic.Tools
  alias ProtohackerElixir.Budget.Room
  alias ProtohackerElixir.Budget.User
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
    :gen_tcp.send(client_socket, "Welcome to budgetchat! What shall I call you?\n")
    {:next_state, :awaiting_name, data, [{:next_event, :internal, :await_name}]}
  end

  def handle_event(
        :internal,
        :await_name,
        :awaiting_name,
        state = %{client_socket: client_socket}
      ) do
    with {:recv_data, {:ok, data}} <- {:recv_data, :gen_tcp.recv(client_socket, 0)},
         name = data |> String.trim(),
         {:is_name_valid, true} <- {:is_name_valid, User.valid_name?(name)},
         user = %User{name: name, pid: self(), id: Tools.uuid()},
         {:ok} <- Room.join(user) do
      {:next_state, :joined, state}
    else
      _ -> {:next_state, :killed, state, [{:next_event, :internal, :kill}]}
    end
  end

  def handle_event(:enter, _, :joined, state) do
    %{user: user, client_socket: client_socket} = state
    Logger.debug("User enter join state: #{inspect(user)}")

    case Room.get_room_members(user) do
      {:ok, members} ->
        Logger.debug("Get room members: #{members}")
        pn = Message.PresenceNotification.new(members)
        :gen_tcp.send(client_socket, pn)

      {:error, reason} ->
        Logger.error("Get room member fail: #{inspect(reason)}")
    end

    {:keep_state_and_data, []}
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

  def handle_event(:cast, {:recv_msg, message}, currentState, data) do
    Logger.debug("Client receive #{message} on state #{currentState} with data #{inspect(data)}")
    {:keep_state_and_data, []}
  end
end
