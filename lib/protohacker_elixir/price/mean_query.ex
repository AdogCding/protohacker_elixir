defmodule ProtohackerElixir.Price.MeanQuery do
  defstruct [:mintime, :maxtime]

  @type t::%__MODULE__{
    mintime: integer(),
    maxtime: integer()
  }
end
