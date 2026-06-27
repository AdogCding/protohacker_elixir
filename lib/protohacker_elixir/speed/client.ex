defmodule ProtohackerElixir.Speed.Client do
  require Logger
  alias ProtohackerElixir.Speed.ClientMessageHandler
  alias ProtohackerElixir.Speed.DataType.Plate
  alias ProtohackerElixir.Speed.DataType.IAmDispatcher
  alias ProtohackerElixir.Speed.DataType.IAmCamera
  alias ProtohackerElixir.Speed.DataType.Error
  alias ProtohackerElixir.Speed.SerializableUtils
  alias ProtohackerElixir.Speed.DataType.Heartbeat
  alias ProtohackerElixir.Speed.DataType.BadMessage
  alias ProtohackerElixir.Speed.DataType.WantHeartbeat
  alias ProtohackerElixir.Speed.DataType
  use GenServer

  def start_link(init_args) do
    socket = Keyword.get(init_args, :socket)
    GenServer.start_link(__MODULE__, %{socket: socket})
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
        {:tcp, _socket, income_data},
        %{data: data} = state
      ) do
    full_buffer = income_data <> data
    Logger.debug("Client received message:#{full_buffer}")
    {messages, rest_bytes} = DataType.parse_all(full_buffer)

    is_ok =
      messages
      |> Enum.reduce_while({true}, fn msg, {is_ok} ->
        case ClientMessageHandler.process_client_msg(msg) do
          :ok -> {:cont, {is_ok}}
          :error -> {:halt, {false}}
        end
      end)

    case is_ok do
      true ->
        {:noreply, %{state | data: rest_bytes}}

      _ ->
        {:terminate}
    end
  end

  def handle_info({:setup_heartbeat_interval, interval}, %{heartbeat_interval: nil} = state) do
    :timer.send_after(div(interval, 10), :heartbeat)
    {:noreply, %{state | heartbeat_interval: interval}}
  end

  def handle_info(
        {:setup_heartbeat_interval, interval},
        %{socket: socket, heartbeat_interval: interval} = state
      ) do
    SerializableUtils.send_data(socket, %Error{msg: "Heartbeat already setup"})
    {:stop, :heartbeat_already_setup, state}
  end

  def handle_info(:heartbeat, %{socket: socket}) do
    SerializableUtils.send_data(socket, %Heartbeat{})
  end
end
