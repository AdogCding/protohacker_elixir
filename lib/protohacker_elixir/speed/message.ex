defmodule ProtohackerElixir.Speed.Message do
  @callback new(binary()) :: {:ok, struct(), binary()} | {:error, term()}
end
