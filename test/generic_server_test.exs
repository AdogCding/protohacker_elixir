defmodule GenericServerTest do
  use ExUnit.Case, async: false
  require Logger

  defmodule MockChallenge do
    # 针对 task_type: :task 的测试路径
    def handle_connection(socket) do
      :ok = :gen_tcp.send(socket, "hello_from_task")
      :gen_tcp.close(socket)
    end

    # 针对 task_type: :dynamic 的测试路径
    use GenServer, restart: :transient
    def start_link(args), do: GenServer.start_link(__MODULE__, args)

    def init(args) do
      # 🌟 绝招：向测试进程发送消息，证明自己被正确启动了，且拿到了 socket
      send(:test_coordinator, {:dynamic_started, args})
      {:ok, args}
    end
  end

  setup do
    on_exit(fn ->
      if Process.whereis(:test_coordinator), do: Process.unregister(:test_coordinator)

      # 强制超度 DynamicSupervisor 下挂载的所有陈年老员工
      ProtohackerElixir.Generic.DynamicSupervisor
      |> DynamicSupervisor.which_children()
      |> Enum.each(fn {_id, child_pid, _type, _modules} ->
        DynamicSupervisor.terminate_child(ProtohackerElixir.Generic.DynamicSupervisor, child_pid)
      end)

      ProtohackerElixir.Generic.TaskSupervisor
      |> Task.Supervisor.children()
      |> Enum.each(fn {pid} ->
        Logger.debug("Terminating task child: #{inspect(pid)}")
        Task.Supervisor.terminate_child(Task.Supervisor, pid)
      end)
    end)
  end

  test "Generic.Server with task_type :task" do
    port = 10_005

    # 启动 Generic.Server
    _pid =
      start_supervised!(
        {ProtohackerElixir.Generic.Server,
         port: port,
         challenge: MockChallenge,
         task_type: :task,
         socket_opts: [:binary, active: false, reuseaddr: true]}
      )

    # 模拟客户端连接
    {:ok, socket} = :gen_tcp.connect(~c"localhost", port, [:binary, active: false])
    {:ok, response} = :gen_tcp.recv(socket, 0, 1_000)
    assert response == "hello_from_task"
    :gen_tcp.close(socket)
  end

  test "task_type 为 :dynamic 时，能够成功将子进程注册进 DynamicSupervisor" do
    # 将当前测试进程命名为 :test_coordinator，方便 MockChallenge 跨进程给它发消息
    Process.register(self(), :test_coordinator)
    port = 20_002

    _pid =
      start_supervised!(
        {ProtohackerElixir.Generic.Server,
         port: port,
         challenge: MockChallenge,
         task_type: :dynamic,
         socket_opts: [:binary, active: false, reuseaddr: true]}
      )

    # 模拟客户端连接
    {:ok, client_socket} = :gen_tcp.connect(~c"localhost", port, [:binary, active: false])

    # 断言：测试进程应该能在 1 秒内收到子进程启动成功的喜报
    assert_receive {:dynamic_started, child_args}, 1000
    assert child_args.challenge == MockChallenge
    # 确保 socket 传过去了
    assert is_port(child_args.client_socket)
    :gen_tcp.close(client_socket)
  end
end
