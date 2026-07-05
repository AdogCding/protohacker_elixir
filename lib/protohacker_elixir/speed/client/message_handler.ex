defmodule ProtohackerElixir.Speed.Client.MessageHandler do
  alias ProtohackerElixir.Speed.TicketManager
  alias ProtohackerElixir.Speed.Serializable
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer.CameraRecord
  alias ProtohackerElixir.Speed.Database
  alias ProtohackerElixir.Speed.Client.ClientState
  alias ProtohackerElixir.Speed.DataType.Plate
  alias ProtohackerElixir.Speed.DataType.IAmDispatcher
  alias ProtohackerElixir.Speed.DataType.IAmCamera
  alias ProtohackerElixir.Speed.DataType.WantHeartbeat
  alias ProtohackerElixir.Speed.DataType.Error
  require Logger

  def process_client_msg(
        %ClientState{socket: socket, pid: pid},
        %WantHeartbeat{interval: interval} = msg
      ) do
    Process.send(pid, {:setup_hearbeat, interval}, [])
    :gen_tcp.send(socket, Serializable.Helper.serialize(msg))
  end

  @spec process_client_msg(ClientState.t(), IAmCamera.t()) ::
          {:ok, ClientState.t()} | {:error, ClientState.t()}
  def process_client_msg(
        %ClientState{role: role, socket: socket} = client_state,
        %IAmCamera{road: road, mile: mile, limit: limit}
      ) do
    case role do
      :unrecognized ->
        {:ok, %ClientState{client_state | role: :camera, road: road, mile: mile, limit: limit}}
        # 保存道路信息
        Database.RoadDbServer.insert_road(%Database.RoadDbServer.Road{
          road: road,
          limit: limit
        })

        # 注册摄像头信息
        Registry.register(ProtohackerElixir.Speed.CameraRegistry, road, {self()})

      _ ->
        :gen_tcp.send(
          socket,
          Serializable.Helper.serialize(%Error{msg: "I am identified as #{role}"})
        )

        {:error, client_state}
    end
  end

  @spec process_client_msg(ClientState.t(), IAmDispatcher.t()) ::
          {:ok, ClientState.t()} | {:error, ClientState.t()}
  def process_client_msg(%ClientState{socket: socket, role: role} = client_state, %IAmDispatcher{
        roads: roads
      }) do
    case role do
      :unrecognized ->
        {:ok, %ClientState{client_state | role: :dispatcher, roads: roads}}

        for r <- roads do
          # 注册调度器信息
          Registry.register(ProtohackerElixir.Speed.DispatcherRegistry, r, {self()})
        end

      _ ->
        :gen_tcp.send(
          socket,
          Serializable.Helper.serialize(%Error{msg: "I am identified as #{role}"})
        )

        {:error, client_state}
    end
  end

  def process_client_msg(
        %ClientState{socket: socket, role: role, road: road, mile: mile} = client_state,
        %Plate{
          plate: plate,
          timestamp: timestamp
        }
      ) do
    case role do
      :camera ->
        # 保存接受到监控记录
        camera_record = %CameraRecord{
          plate: plate,
          timestamp: timestamp,
          road: road,
          mile: mile
        }

        TicketManager.try_generate_ticket(camera_record)
        :ok

      _ ->
        :gen_tcp.send(
          socket,
          Serializable.Helper.serialize(%Error{msg: "Plate cannot be sent to #{role}"})
        )

        {:error, client_state}
    end
  end

  @spec process_client_msg(ClientState.t(), any()) :: :ok
  def process_client_msg(%ClientState{}, msg) do
    Logger.debug("unexpected msg #{inspect(msg)}")
  end
end
