defmodule ProtohackerElixir.Speed.TicketManager.Generator do
  @moduledoc """
  负责罚单的产生
  """
  alias ProtohackerElixir.Generic.Tools
  alias ProtohackerElixir.Speed.SpeedLimitHelper.Witness
  alias ProtohackerElixir.Speed.Database.RoadDbServer.Road
  alias ProtohackerElixir.Speed.Database.RoadDbServer
  alias ProtohackerElixir.Speed.SpeedLimitHelper
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer.CameraRecord
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer
  alias ProtohackerElixir.Speed.Database.TicketDbServer.Ticket

  # 核心逻辑，判断是否要产生罚单
  @spec try_generate_ticket(CameraRecord.t()) :: [Ticket.t()]
  def try_generate_ticket(
        %CameraRecord{plate: plate, road: road, mile: mile1, timestamp: timestamp1} =
          camera_record
      ) do
    camera_records = CameraRecordDbServer.query_camera_record_by_plate(plate)
    road = RoadDbServer.query_road(road)

    if camera_records |> Enum.empty?() do
      CameraRecordDbServer.insert_camera_record(camera_record)
    else
      bad_camera_records =
        camera_records |> Enum.filter(&bad_camera_record?(road, {&1, camera_record}))

      for %CameraRecord{mile: mile2, timestamp: timestamp2} <- bad_camera_records,
          do: %Ticket{
            plate: plate,
            road: road,
            mile1: mile1,
            timestamp1: timestamp1,
            timestamp2: timestamp2,
            mile2: mile2,
            is_issued: false,
            id: Tools.uuid(),
            speed:
              SpeedLimitHelper.calculate_speed(%Witness{
                mile1: mile1,
                mile2: mile2,
                plate: plate,
                timestamp1: timestamp1,
                timestamp2: timestamp2
              })
          }
    end
  end

  @spec bad_camera_record?(Road.t(), {CameraRecord.t(), CameraRecord.t()}) :: boolean()
  def bad_camera_record?(%Road{limit: limit}, {cr1, cr2}) do
    SpeedLimitHelper.exceed_limit?(
      %Witness{
        mile1: cr1.mile,
        mile2: cr2.mile,
        plate: cr1.plate,
        timestamp1: cr1.timestamp,
        timestamp2: cr2.timestamp
      },
      limit
    )
  end
end
