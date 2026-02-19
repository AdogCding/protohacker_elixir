defmodule ProtohackerElixir.Generic.Challenge do
  @callback handle_connection(:gen_tcp.socket()) :: any()
end
