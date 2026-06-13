defmodule ProtohackerElixir.Speed.Client do
  alias ProtohackerElixir.Speed.DataType.Error
  alias ProtohackerElixir.Speed.DataType.Heartbeat
  alias ProtohackerElixir.Speed.SerializableUtils
  alias ProtohackerElixir.Speed.DataType.WantHeartbeat
  alias ProtohackerElixir.Speed.DataType.IAmDispatcher
  alias ProtohackerElixir.Speed.DataType.IAmCamera
  alias ProtohackerElixir.Speed.DataType
  use GenServer

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args)
  end

  def init(init_args) do
    %{socket: socket} = init_args

    {:ok, %{socket: socket, data: <<>>, role: :unrecognized, heartbeat_interval: nil},
     {:continue, :setopts}}
  end

  def handle_continue(:setopts, state) do
    :inet.setopts(state.socket, active: :once)
    {:noreply, state}
  end

  def handle_info(
        {:tcp, _socket, data},
        %{role: :unrecogized, heartbeat_interval: heartbeat} = state
      ) do
    full_data =
      state.data <> data

    res = process_unrecognizor_msg(%{state | data: full_data})
    {:noreply, res}
  end

  defp process_unrecognizor_msg(%{data: data} = state) do
    
  end
end
