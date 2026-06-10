defmodule ProtohackerElixir.Speed.Helper do
  alias ProtohackerElixir.Speed.Witness

  @spec calculate_speed(Witness.t()) :: integer()
  def calculate_speed(%Witness{
        mile1: mile1,
        mile2: mile2,
        timestamp1: timestamp1,
        timestamp2: timestamp2
      }) do
    distance = abs(mile2 - mile1)
    interval = abs(timestamp2 - timestamp1) / 60 / 60
    distance / interval * 100
  end

  @spec exceed_limit?(Witness.t(), float()) :: boolean()
  def exceed_limit?(witness, limit) do
    speed = calculate_speed(witness)
    diff = speed - limit

    if diff <= 0 do
      false
    else
      # In cases where the car is exceeding the speed limit by less than 0.5 mph, it is acceptable to omit the ticket.
      diff > 0.5 * 100
    end
  end
end
