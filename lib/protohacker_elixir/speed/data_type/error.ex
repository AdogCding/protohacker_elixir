defmodule ProtohackerElixir.Speed.DataType.Error do
  defstruct msg: nil

  @type t :: %__MODULE__{
          msg: String.t()
        }
end
