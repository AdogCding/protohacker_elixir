defmodule ProtohackerElixir.Speed.Client do
  require Logger
  alias ProtohackerElixir.Speed.Client.ClientState
  alias ProtohackerElixir.Speed.SerializableUtils
  alias ProtohackerElixir.Speed.ClientMessageHandler
  alias ProtohackerElixir.Speed.DataType
  use GenServer

  def start_link(init_args) do
    socket = Keyword.get(init_args, :socket)
    GenServer.start_link(__MODULE__, %{socket: socket})
  end

  def init(init_args) do
    %{socket: socket} = init_args

    {:ok,
     %ClientState{
       socket: socket,
       data: <<>>,
       role: :unrecognized,
       heartbeat_interval: nil,
       pid: self()
     }, {:continue, :setopts}}
  end

  def handle_continue(:setopts, state) do
    :inet.setopts(state.socket, active: :once)
    {:noreply, state}
  end

  def handle_info({:setup_heartbeat, interval}, state) do
    :timer.send_interval(interval * 100, :heartbeat)
    {:noreply, %{state | heartbeat_interval: interval}}
  end

  def handle_info(:heartbeat, %{socket: socket} = state) do
    :gen_tcp.send(socket, SerializableUtils.serialize(%DataType.Heartbeat{}))
    {:noreply, state}
  end

  def handle_info(
        {:tcp, _socket, income_data},
        %{data: data} = state
      ) do
    full_buffer = income_data <> data
    Logger.debug("Client received message:#{full_buffer}")
    {messages, rest_bytes} = DataType.parse_all(full_buffer)

    client_state = %ClientState{
      socket: state.socket,
      role: state.role,
      heartbeat_interval: state.heartbeat_interval,
      pid: self(),
      data: rest_bytes
    }

    {new_client_state, is_ok} =
      messages
      |> Enum.reduce_while({client_state, true}, fn msg, {client_state, is_ok} ->
        case ClientMessageHandler.process_client_msg(client_state, msg) do
          {:ok, client_state} -> {:cont, {client_state, is_ok}}
          {:error, client_state} -> {:halt, {client_state, false}}
        end
      end)

    case is_ok do
      true ->
        {:noreply, new_client_state}

      _ ->
        {:terminate}
    end
  end
end
