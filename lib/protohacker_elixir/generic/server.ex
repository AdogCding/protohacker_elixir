defmodule ProtohackerElixir.Generic.Server do
  use GenServer, restart: :transient
  require Logger

  @default_socket_opts [
    :binary,
    active: false,
    reuseaddr: true
  ]

  def start_link(opts) do
    port = Keyword.get(opts, :port)
    challenge = Keyword.get(opts, :challenge)
    socket_opts = Keyword.get(opts, :socket_opts, @default_socket_opts)
    task_type = Keyword.get(opts, :task_type)

    GenServer.start_link(__MODULE__, %{
      port: port,
      challenge: challenge,
      socket_opts: socket_opts,
      task_type: task_type
    })
  end

  @impl true
  def init(init_args) do
    %{port: port, challenge: challenge, socket_opts: socket_opts, task_type: task_type} =
      init_args

    Logger.debug("Start #{inspect(challenge)} application at #{port}")

    case :gen_tcp.listen(port, socket_opts) do
      {:ok, socket} ->
        {:ok, %{socket: socket, challenge: challenge, task_type: task_type},
         {:continue, :accept_loop}}

      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_continue(:accept_loop, state = %{socket: socket}) do
    with {:ok, client_socket} <- :gen_tcp.accept(socket, 1000 * 60),
         {:ok, pid} <-
           start_task(client_socket, state),
         :ok <- :gen_tcp.controlling_process(client_socket, pid) do
      send(pid, :socket_transferred)
      {:noreply, state, {:continue, :accept_loop}}
    else
      {:error, reason} -> {:stop, reason}
    end
  end

  defp start_task(client_socket, %{task_type: :task, challenge: challenge}) do
    Task.Supervisor.start_child(ProtohackerElixir.Generic.TaskSupervisor, fn ->
      challenge.handle_connection(client_socket)
    end)
  end

  defp start_task(client_socket, init_args = %{task_type: :dynamic, challenge: challenge}) do
    child_args = Map.put(init_args, :client_socket, client_socket)

    DynamicSupervisor.start_child(
      ProtohackerElixir.Generic.DynamicSupervisor,
      {challenge, child_args}
    )
  end
end
