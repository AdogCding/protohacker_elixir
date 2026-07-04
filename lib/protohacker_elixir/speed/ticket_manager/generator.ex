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
  @spec try_generate_ticket(String.t(), integer()) :: [Ticket.t()]
  def try_generate_ticket(plate, road) do
    camera_records = CameraRecordDbServer.query_camera_record_by_plate(plate)
    road = RoadDbServer.query_road(road)

    lookingfor_possible_illegal_camera_record(camera_records, [], road)
    |> Enum.map(fn {%CameraRecord{plate: plate, road: road, mile: mile1, timestamp: timestamp1},
                    %CameraRecord{mile: mile2, timestamp: timestamp2}} ->
      %Ticket{
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
    end)
  end

  defp lookingfor_possible_illegal_camera_record([], result, _road) do
    result
  end

  @spec lookingfor_possible_illegal_camera_record(
          [CameraRecord.t()],
          [CameraRecord.t()],
          Road.t()
        ) :: [CameraRecord.t()]
  defp lookingfor_possible_illegal_camera_record(
         [%CameraRecord{mile: mile, timestamp: timestamp} = base_camera_record | tail],
         result,
         %Road{limit: limit} = road
       ) do
    bad_camera_record =
      Enum.filter(tail, fn %CameraRecord{plate: plate, mile: cr_mile, timestamp: cr_timestamp} ->
        SpeedLimitHelper.exceed_limit?(
          %Witness{
            plate: plate,
            mile1: cr_mile,
            mile2: mile,
            timestamp1: cr_timestamp,
            timestamp2: timestamp
          },
          limit / 1
        )
      end)

    bad_camera_record_pairs = for i <- bad_camera_record, do: {base_camera_record, i}

    lookingfor_possible_illegal_camera_record(
      if(bad_camera_record |> Enum.empty?(), do: result, else: result ++ bad_camera_record_pairs),
      tail,
      road
    )
  end
end
