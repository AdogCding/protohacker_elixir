defmodule ProtohackerElixir.Budget.User do
  def valid_name?(name) do
    name |> String.length() > 0 and String.match?(name, ~r/^[a-zA-Z0-9]+$/)
  end
end
