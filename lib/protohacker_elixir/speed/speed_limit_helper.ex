defmodule ProtohackerElixir.Speed.SpeedLimitHelper do
  alias ProtohackerElixir.Speed.SpeedLimitHelper.Witness

  # return mph
  @spec calculate_mph_speed(Witness.t()) :: float()
  def calculate_mph_speed(%Witness{
        mile1: mile1,
        mile2: mile2,
        timestamp1: timestamp1,
        timestamp2: timestamp2
      }) do
    distance = abs(mile2 - mile1)
    interval = abs(timestamp2 - timestamp1) / 60 / 60
    distance / interval
  end

  @spec calculate_speed(Witness.t()) :: integer()
  def calculate_speed(w) do
    (calculate_mph_speed(w) * 100) |> round()
  end

  @spec calculate_day(integer()) :: integer()
  def calculate_day(timestamp) do
    floor(timestamp / 86400)
  end

  @spec caculate_days(integer(), integer()) :: [integer()]
  def caculate_days(timestamp1, timestamp2) do
    day1 = calculate_day(timestamp1)
    day2 = calculate_day(timestamp2)
    Enum.to_list(min(day1, day2)..max(day1, day2))
  end

  @spec exceed_limit?(Witness.t(), float()) :: boolean()
  def exceed_limit?(witness, limit) do
    speed = calculate_mph_speed(witness)
    diff = speed - limit

    if diff <= 0 do
      false
    else
      # In cases where the car is exceeding the speed limit by less than 0.5 mph, it is acceptable to omit the ticket.
      diff > 0.5
    end
  end
end
