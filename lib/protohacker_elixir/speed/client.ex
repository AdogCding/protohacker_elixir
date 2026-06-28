defmodule ProtohackerElixir.Speed.Client do
  require Logger
  alias ProtohackerElixir.Speed.ClientMessageHandler
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
end
