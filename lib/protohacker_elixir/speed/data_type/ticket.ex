defmodule ProtohackerElixir.Speed.DataType.Ticket do
  alias ProtohackerElixir.Speed.Message

  defstruct plate: nil,
            road: nil,
            mile1: nil,
            timestamp1: nil,
            mile2: nil,
            timestamp2: nil,
            speed: nil

  @behaviour Message

  @type t :: %__MODULE__{
          plate: String.t(),
          road: number(),
          mile1: number(),
          timestamp1: number(),
          mile2: number(),
          timestamp2: number(),
          speed: number()
        }

  @impl true
  def new(
        <<plate_size::unsigned-8, plate::binary-size(plate_size), road::unsigned-16,
          mile1::unsigned-16, timestamp1::unsigned-32, mile2::unsigned-16,
          timestamp2::unsigned-32, speed::unsigned-16, rest::binary>>
      ) do
    msg = %__MODULE__{
      plate: plate,
      road: road,
      mile1: mile1,
      timestamp1: timestamp1,
      mile2: mile2,
      timestamp2: timestamp2,
      speed: speed
    }

    {:ok, msg, rest}
  end

  @impl true
  def new(_) do
    {:error, :not_match}
  end
end
