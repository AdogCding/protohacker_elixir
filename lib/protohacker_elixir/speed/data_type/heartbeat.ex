defmodule ProtohackerElixir.Speed.DataType.Heartbeat do
  defstruct []
  @behaviour ProtohackerElixir.Speed.DataType.Message

  @type t :: %__MODULE__{}

  @impl true
  def new(msg) do
    {:ok, %__MODULE__{}, msg}
  end
end
