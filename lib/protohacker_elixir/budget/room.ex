defmodule ProtohackerElixir.Budget.Room do
  @moduledoc false
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
    GenServer.call(__MODULE__, {:join, user})
  end

  @spec get_room_members(User.t()) :: {:ok, list(User.t())} | {:error, term()}
  def get_room_members(newbee) do
    case GenServer.call(__MODULE__, {:get_room_state}) do
      {:ok, %Chat{clients: clients}} ->
        Logger.debug("Gotten room member: #{inspect(clients)}")
        {:ok, clients |> Map.values() |> Enum.filter(fn c -> c.id != newbee.id end)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec send_message(User.t(), String.t()) :: term()
  def send_message(sender, message) do
    GenServer.cast(__MODULE__, {:send_message, sender, message})
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

  def handle_call({:get_room_state}, _from, state) do
    {:reply, {:ok, state}, state}
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
    Logger.debug("User #{inspect(user)} is leaving")
    %{clients: clients} = state
    new_clients = Map.delete(clients, user.id)
    {:reply, :ok, %{state | clients: new_clients}}
  end
end
