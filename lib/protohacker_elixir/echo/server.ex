defmodule ProtohackerElixir.Echo.Server do
  use GenServer
  require Logger


  def start_link(opts) do
    port = Keyword.get(opts, :port, 1000)
    GenServer.start_link(__MODULE__, %{port: port})
  end

  def init(init_args) do
    %{port: port} = init_args
    Logger.info("Starting on port #{port}")
    {:ok, :normal}
  end

end
