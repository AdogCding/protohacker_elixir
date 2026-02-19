defmodule ProtohackerElixir.Generic.Server do
  use GenServer, restart: :transient
  require Logger

  def start_link(opts) do
    port = Keyword.get(opts, :port)
    challenge = Keyword.get(opts, :challenge)
    GenServer.start_link(__MODULE__, %{port: port, challenge: challenge})
  end

  @impl true
  def init(init_args) do
    %{port: port, challenge: challenge} = init_args

    socket_opts = [
      :binary,
      active: false,
      reuseaddr: true
    ]

    case :gen_tcp.listen(port, socket_opts) do
      {:ok, socket} -> {:ok, %{socket: socket, challenge: challenge}, {:continue, :accept_loop}}
      {:error, reason} -> {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept_loop, state = %{socket: socket, challenge: challenge}) do
    with {:ok, client_socket} <- :gen_tcp.accept(socket, 1000 * 60),
         {:ok, pid} <-
           Task.Supervisor.start_child(ProtohackerElixir.Echo.TaskSupervisor, fn ->
             challenge.handle_connection(client_socket)
           end),
         :ok <- :gen_tcp.controlling_process(client_socket, pid) do
      Logger.debug("Starting work")
      send(pid, :socket_transferred)
      {:noreply, state, {:continue, :accept_loop}}
    else
      {:error, reason} -> {:stop, reason}
    end
  end
end
