defmodule ProtohackerElixir.Speed.DataType.IAmCamera do
  alias ProtohackerElixir.Speed.Message
  defstruct road: nil, mile: nil, limit: nil
  @behaviour Message

  @type t :: %__MODULE__{
          road: number(),
          mile: number(),
          limit: number()
        }

  def new(<<road::unsigned-16, mile::unsigned-16, limit::unsigned-16, rest::binary>>) do
    {:ok,
     %__MODULE__{
       road: road,
       mile: mile,
       limit: limit
     }, rest}
  end

  def new(_) do
    {:error, :not_match}
  end
end
