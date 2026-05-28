defmodule ProtohackerElixir.StrangeDb.DbAcceptor do
  alias ProtohackerElixir.StrangeDb.DbCmdHandler
  alias ProtohackerElixir.StrangeDb.DbServer
  alias ProtohackerElixir.StrangeDb.DbCmd
  use GenServer
  require Logger

  def start_link(opts) do
    port = Keyword.get(opts, :port)
    GenServer.start_link(__MODULE__, %{port: port}, name: __MODULE__)
  end

  def init(init_arg) do
    %{port: port} = init_arg
    opts = [:binary, active: :once]

    case :gen_udp.open(port, opts) do
      {:ok, socket} ->
        Logger.debug("Start StrangeDb acceptor at #{port}")
        {:ok, %ProtohackerElixir.StrangeDb.DbAcceptorData{socket: socket}}

      {:error, reason} ->
        Logger.error("Failed to start StrangeDb acceptor at #{port}: #{reason}")
        {:stop, reason}
    end
  end

  def handle_info(
        {:udp, socket, ip, port, packet},
        %ProtohackerElixir.StrangeDb.DbAcceptorData{socket: socket} = state
      ) do
    Logger.debug("Received packet from #{inspect(ip)}:#{port} with content: #{inspect(packet)}")

    {k, v} =
      case DbCmdHandler.parse_cmd(packet |> String.trim()) do
        {:ok, %DbCmd{cmd: :insert, key: key, value: value}} ->
          DbServer.insert(key, value)
          nil

        {:ok, %DbCmd{cmd: :retrieve, key: key}} ->
          DbServer.retrieve(key)

        {:error, _} ->
          Logger.warning("Failed to parse command from packet: #{inspect(packet)}")
          nil
      end

    Logger.debug("Database server will response with #{k}, #{v}")

    case {k, v} do
      {_, nil} ->
        :ok

      _ ->
        Logger.debug(
          "Sending response to #{inspect(ip)}:#{port} with content: #{inspect({k, v})}"
        )

        case :gen_udp.send(socket, ip, port, "#{k}=#{v}") do
          :ok ->
            Logger.debug("Response sent successfully to #{inspect(ip)}:#{port}")

          {:error, reason} ->
            Logger.error("Failed to send response to #{inspect(ip)}:#{port}: #{reason}")
        end
    end

    :inet.setopts(socket, [{:active, :once}])
    {:noreply, state}
  end
end
