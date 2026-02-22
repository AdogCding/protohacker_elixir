defmodule ProtohackerElixir.Budget.Room do
  alias ProtohackerElixir.Budget.User
  alias ProtohackerElixir.Budget.Chat
  use GenServer
  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    alias ProtohackerElixir.Budget.Chat
    {:ok, %Chat{clients: %{}, messages: []}}
  end

  @spec join(User.t()) :: term()
  def join(user) do
    GenServer.cast(__MODULE__, {:join, user})
  end

  @spec send_message(User.t(), String.t()) :: term()
  def send_message(user, message) do
    GenServer.cast(__MODULE__, {:send_message, user, message})
  end

  @spec leave(User.t()) :: term()
  def leave(user) do
    GenServer.call(__MODULE__, {:leave, user})
  end

  @impl true
  def handle_call({:join, user}, _from, state) do
    new_clients = Map.put(state.clients, user.id, user)
    {:reply, :ok, %{state | clients: new_clients}}
  end

  def handle_call({:send_message, sender, message}, _from, state) do
    %{clients: clients, messages: _messages} = state
    %{id: sender_id} = sender

    Map.values(clients)
    |> Enum.each(fn client ->
      %User{id: id, pid: pid, name: name} = client

      case id do
        ^sender_id ->
          Logger.debug("Not sending message to sender #{name} (#{id})")

        _ ->
          Logger.debug("Sending message to #{name} (#{id})")
          :gen_statem.cast(pid, {:recv_msg, message})
      end
    end)
  end

  @impl true
  def handle_call({:leave, user}, _from, state) do
    new_clients = Map.delete(state.clients, user.id)
    {:reply, :ok, %{state | clients: new_clients}}
  end
end
