defmodule ProtohackerElixir.Prime.Helper do
  @moduledoc false
  def prime?(n) when is_integer(n) and n < 2, do: false
  def prime?(2), do: true

  def prime?(n) when is_integer(n) do
    not Enum.any?(2..trunc(:math.sqrt(n))//1, fn x -> rem(n, x) == 0 end)
  end

  def prime?(_), do: false
end
