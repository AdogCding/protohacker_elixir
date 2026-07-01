defmodule ProtohackerElixir.Speed.TicketManager.TicketGenerator do
  @moduledoc """
  负责罚单的产生
  """
  alias ProtohackerElixir.Speed.SpeedLimitHelper.Witness
  alias ProtohackerElixir.Speed.Database.RoadDbServer.Road
  alias ProtohackerElixir.Speed.Database.RoadDbServer
  alias ProtohackerElixir.Speed.SpeedLimitHelper
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer.CameraRecord
  alias ProtohackerElixir.Speed.Database.CameraRecordDbServer
  alias ProtohackerElixir.Speed.DataType.Ticket

  # 核心逻辑，判断是否要产生罚单
  @spec try_generate_ticket(String.t(), integer()) :: Ticket.t()
  def try_generate_ticket(plate, road) do
    camera_records = CameraRecordDbServer.query_camera_record(plate, road)
    road = RoadDbServer.query_road(road)
    lookingfor_possible_illegal_camera_record(road, camera_records, [])
  end

  defp lookingfor_possible_illegal_camera_record([], result, road) do
    result
  end

  defp lookingfor_possible_illegal_camera_record(
         [%CameraRecord{mile: mile, timestamp: timestamp} | tail],
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

    lookingfor_possible_illegal_camera_record(
      road,
      tail,
      if(bad_camera_record |> Enum.empty?(), do: result, else: result ++ bad_camera_record)
    )
  end
end
