defmodule ProtohackerElixir.Echo.Server do
  use GenServer, restart: :transient
  require Logger

  def start_link(opts) do
    port = Keyword.get(opts, :port, 1000)
    GenServer.start_link(__MODULE__, %{port: port})
  end

  @impl true
  def init(init_args) do
    %{port: port} = init_args

    socket_opts = [
      :binary,
      packet: :line,
      active: false,
      reuseaddr: true
    ]

    case :gen_tcp.listen(port, socket_opts) do
      {:ok, socket} -> {:ok, %{socket: socket}, {:continue, :accept_loop}}
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept_loop, state = %{socket: socket}) do
    with {:ok, client_socket} <- :gen_tcp.accept(socket, 1000 * 60),
         {:ok, pid} <-
           Task.Supervisor.start_child(ProtohackerElixir.Echo.TaskSupervisor, fn ->
             ProtohackerElixir.Echo.Worker.start_link(client_socket)
           end),
         :ok <- :gen_tcp.controlling_process(client_socket, pid) do
      send(pid, :socket_transferred)
      {:noreply, state, {:continue, :accept_loop}}
    else
      {:error, reason} -> {:stop, reason}
    end
  end
end
