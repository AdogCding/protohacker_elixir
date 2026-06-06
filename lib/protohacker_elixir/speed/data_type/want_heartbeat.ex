defmodule ProtohackerElixir.Speed.DataType.WantHeartbeat do
  defstruct interval: nil

  @type t :: %__MODULE__{
          interval: number()
        }
  def new(<<interval::unsigned-32, rest::binary>>) do
    {:ok,
     %__MODULE__{
       interval: interval
     }, rest}
  end
end
