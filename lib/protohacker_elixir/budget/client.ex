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
         :ok <- Room.join(user) do
      {:next_state, :joined, Map.put(state, :user, user),
       [{:next_event, :internal, :waiting_for_message}]}
    else
      _ -> {:next_state, :killed, state, [{:next_event, :internal, :kill}]}
    end
  end

  def handle_event(:enter, _, :joined, state) do
    %{user: user, client_socket: client_socket} = state
    Logger.debug("User enter join state: #{inspect(user)}")

    case Room.get_room_members(user) do
      {:ok, members} ->
        Logger.debug("Get room members: #{inspect(members)}")
        pn = Message.PresenceNotification.new(members)
        :gen_tcp.send(client_socket, pn)

      {:error, reason} ->
        Logger.error("Get room member fail: #{inspect(reason)}")
    end

    {:keep_state_and_data, []}
  end

  def handle_event(:internal, :waiting_for_message, :joined, state) do
    %{client_socket: client_socket} = state

    case :inet.setopts(client_socket, [{:active, :once}]) do
      :ok ->
        Logger.debug("Set client socket to active once")

      {:error, reason} ->
        Logger.error("Failed to set client socket to active once: #{inspect(reason)}")
    end

    {:keep_state_and_data, []}
  end

  def handle_event(:internal, :kill, :killed, data) do
    Logger.debug("Client is going to be killed")
    %{client_socket: client_socket, user: user} = data
    Room.leave(user)
    :gen_tcp.close(client_socket)
    {:stop, :normal, data}
  end

  def handle_event(:enter, oldState, currentState, data) do
    Logger.debug(
      "Client entering state #{inspect(currentState)} from #{inspect(oldState)} with data #{inspect(data)}"
    )

    {:keep_state_and_data, []}
  end

  def handle_event(:cast, {:recv_msg, message}, currentState, data) do
    Logger.debug("Client receive #{message} on state #{currentState} with data #{inspect(data)}")
    %{client_socket: client_socket} = data
    :gen_tcp.send(client_socket, message)
    {:keep_state_and_data, []}
  end

  def handle_event(:info, :socket_transferred, _currentState, data) do
    Logger.debug("Client handle_event :info: :socket_transferred, #{inspect(data)}")
    {:next_state, :ready, data, [{:next_event, :internal, :send_welcome_and_await_name}]}
  end

  def handle_event(:info, {:tcp, socket, data}, :joined, state) do
    Logger.debug("Received message: #{data}")
    %{user: user} = state
    chat_message = Message.ChatMessage.new(user, data |> String.trim())
    Room.send_message(user, chat_message)
    :inet.setopts(socket, [{:active, :once}])
    {:keep_state_and_data, []}
  end

  def handle_event(:info, {:tcp_closed, _socket}, :joined, data) do
    Logger.debug("Tcp closed")
    %{user: user} = data
    Room.leave(user)
    {:stop, :normal, data}
  end

  def handle_event(:info, info, currentState, data) do
    Logger.debug(
      "Client handle_event :info: #{inspect(info)}, #{inspect(currentState)}, #{inspect(data)}"
    )

    {:keep_state_and_data, []}
  end
end
