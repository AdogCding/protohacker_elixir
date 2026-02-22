defmodule ProtohackerElixir.Budget.Room do
  alias ProtohackerElixir.Budget.User
  alias ProtohackerElixir.Budget.Chat
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    alias ProtohackerElixir.Budget.Chat
    {:ok, %Chat{}}
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

end
