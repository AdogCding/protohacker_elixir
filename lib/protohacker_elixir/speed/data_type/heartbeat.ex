defmodule ProtohackerElixir.Speed.DataType.Heartbeat do
  defstruct []
  @behaviour ProtohackerElixir.Speed.Message

  @type t :: %__MODULE__{}

  @impl true
  def new(_) do
    %__MODULE__{}
  end
end
