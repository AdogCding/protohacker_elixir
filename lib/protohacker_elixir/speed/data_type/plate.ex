defmodule ProtohackerElixir.Speed.DataType.Plate do
  alias ProtohackerElixir.Speed.Message
  defstruct plate: nil, timestamp: nil

  @behaviour Message

  @type t :: %__MODULE__{
          plate: String.t(),
          timestamp: number()
        }

  @impl true
  def new(
        <<plate_size::unsigned-8, plate::binary-size(plate_size), timestamp::unsigned-32,
          rest::binary>>
      ) do
    {:ok, %__MODULE__{plate: plate, timestamp: timestamp}, rest}
  end

  @impl true
  def new(_) do
    {:error, :not_match}
  end
end
