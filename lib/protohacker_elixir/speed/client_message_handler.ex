defmodule ProtohackerElixir.Speed.ClientMessageHandler do
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer.CameraRecord
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer
  alias ProtohackerElixir.Speed.Client.ClientState
  alias ProtohackerElixir.Speed.DataType.Plate
  alias ProtohackerElixir.Speed.SerializableUtils
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
    :gen_tcp.send(socket, SerializableUtils.serialize(msg))
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

      _ ->
        :gen_tcp.send(
          socket,
          SerializableUtils.serialize(%Error{msg: "I am identified as #{role}"})
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

      _ ->
        :gen_tcp.send(
          socket,
          SerializableUtils.serialize(%Error{msg: "I am identified as #{role}"})
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
        CameraRecordDbServer.insert_camera_record(%CameraRecord{
          plate: plate,
          timestamp: timestamp,
          road: road,
          mile: mile
        })

      _ ->
        :gen_tcp.send(
          socket,
          SerializableUtils.serialize(%Error{msg: "Plate cannot be sent to #{role}"})
        )

        {:error, client_state}
    end
  end

  @spec process_client_msg(ClientState.t(), any()) :: :ok
  def process_client_msg(%ClientState{}, msg) do
    Logger.debug("unexpected msg #{inspect(msg)}")
  end
end
