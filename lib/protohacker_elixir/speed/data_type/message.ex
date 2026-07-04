defmodule ProtohackerElixir.Speed.DataType.Message do
  @callback new(binary()) :: {:ok, struct(), binary()} | {:error, term()}
end
