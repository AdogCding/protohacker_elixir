defmodule ProtohackerElixir.Echo.Server do
  use GenServer
  require Logger
  @task_name Echo.Worker


  def start_link(opts) do
    port = Keyword.get(opts, :port, 1000)
    GenServer.start_link(__MODULE__, %{port: port})
  end

  @impl true
  def init(init_args) do
    %{port: port} = init_args
    socket_opts = [
      :binary, packet: :line, active: false, reuseaddr: true
    ]
    case :gen_tcp.listen(port, socket_opts) do
      {:ok, socket} -> {:ok, %{socket: socket}, {:continue, :accept_loop}}
      {:error, reason} -> {:stop, reason}
    end
  end


  @impl true
  def handle_continue(:accept_loop, %{socket: socket}) do
    case :gen_tcp.accept(socket) do
      {:ok, client_socket} ->
        {:ok, pid} = Task.Supervisor.start_child(
          ProtohackerElixir.Echo.TaskSupervisor,
          fn -> ProtohackerElixir.Echo.Worker.work(client_socket) end
        )
        :gen_tcp.controlling_process(client_socket, )
    end
  end
end
