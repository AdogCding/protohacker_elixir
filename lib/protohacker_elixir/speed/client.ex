defmodule ProtohackerElixir.Speed.Client do
  use GenServer

  def start_link(init_args) do
    GenServer.start_link(__MODULE__, init_args)
  end

  def init(init_args) do
    %{socket: socket} = init_args
    {:ok, %{socket: socket, data: <<>>, role: :unrecognized}, {:continue, :setopts}}
  end

  def handle_continue(:setopts, state) do
    :inet.setopts(state.socket, active: :once)
    {:noreply, state}
  end

  def handle_info({:tcp, _socket, data}, %{role: :unrecogized} = state) do
    buffer =
      state.data <> data

    {:noreply, %{state | data: state.data <> data}}
  end
end
