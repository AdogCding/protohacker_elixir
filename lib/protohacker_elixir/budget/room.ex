defmodule ProtohackerElixir.Budget.Room do
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

  def join(client_pid, name) do
    GenServer.cast(__MODULE__, {:join, client_pid, name})
  end

  def send_message(name, message) do
    GenServer.cast(__MODULE__, {:send_message, name, message})
  end

  def leave(name) do
    
  end
end
