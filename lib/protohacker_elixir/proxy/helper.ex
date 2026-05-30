defmodule ProtohackerElixir.Proxy.Helper do
  @moduledoc false
  @boguscoin_regex ~r/(?<=^| )7[a-zA-Z0-9]{26,35}(?=[ \n\r]|$)/

  def replace_boguscoin_address(message, address) do
    Regex.replace(@boguscoin_regex, message, address)
  end
end
