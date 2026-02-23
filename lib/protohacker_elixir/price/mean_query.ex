defmodule ProtohackerElixir.Price.MeanQuery do
  @moduledoc false
  defstruct [:mintime, :maxtime]

  @type t :: %__MODULE__{
          mintime: integer(),
          maxtime: integer()
        }
end
