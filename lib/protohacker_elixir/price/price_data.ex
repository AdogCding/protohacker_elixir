defmodule ProtohackerElixir.Price.PriceData do
  defstruct [:message_type, :timestamp, :price]

  @type t :: %__MODULE__{
    timestamp: integer(),
    price: integer(),
    message_type: :insert | :query
  }
end
