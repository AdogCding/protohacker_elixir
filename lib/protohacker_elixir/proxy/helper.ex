defmodule ProtohackerElixir.Proxy.Helper do
  @moduledoc false

  def is_boguscoin_address?(address) do
    String.starts_with?(address, "7") and
      Regex.match?(~r/^[a-zA-Z0-9]+$/, address) and
      String.length(address) >= 26 and
      String.length(address) <= 35
  end
end
