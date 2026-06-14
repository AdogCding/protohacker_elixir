defmodule ProtohackerElixir.Speed.Acceptor do
  alias ProtohackerElixir.Speed.Client
  alias ProtohackerElixir.Speed.DataType
  use GenServer

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(init_args) do
    %{client_socket: client_socket} = init_args
    {:ok, %{socket: client_socket}}
  end

  def handle_info(:socket_transferred, state) do
    %{socket: socket} = state
    :inet.setopts(socket, active: :once)
    DynamicSupervisor.start_link(Client, socket: socket)
    {:noreply, state}
  end
end
