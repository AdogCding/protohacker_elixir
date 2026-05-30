defmodule ProtohackerElixir.Proxy.Server do
  require Logger
  use GenServer

  def start_link(opts) do
    # 要代理的地址
    target_addr = Keyword.get(opts, :target_addr)
    target_port = Keyword.get(opts, :target_port)

    GenServer.start_link(__MODULE__, %{target_addr: target_addr, target_port: target_port},
      name: __MODULE__
    )
  end

  def init(init_args) do
    # 连接到要代理的服务器
    %{target_addr: target_addr, target_port: target_port} = init_args
    {:ok, socket} = :gen_tcp.connect(target_addr, target_port, [:binary, active: false])
    {:ok, %{socket: socket}}
  end

  def handle_info({:tcp, _socket, data}, state) do
    # 从服务器接收到数据，打印并继续监听
    Logger.debug("Received from client: #{inspect(data)}")
    :gen_tcp.send(state.socket, data)
    {:noreply, state}
  end
end
