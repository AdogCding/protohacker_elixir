defmodule ProtohackerElixir.Generic.Tools do
  def uuid() do
    uuid(:lower)
  end

  def uuid(:upper) do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :upper)
  end

  def uuid(:lower) do
    :crypto.strong_rand_bytes(16)
    |> Base.encode16(case: :lower)
  end
end
