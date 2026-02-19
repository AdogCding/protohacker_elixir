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
  def handle_continue(:accept_loop, %{socket: socket}) do
    with {:ok, client_socket} <- :gen_tcp.accept(socket, 1000),
         {:ok, pid} <-
           Task.Supervisor.start_child(ProtohackerElixir.Echo.TaskSupervisor, fn -> nil end) do
      :gen_tcp.controlling_process(client_socket, pid)
    else
      {:error, reason} -> {:stop, reason}
    end
  end
end
