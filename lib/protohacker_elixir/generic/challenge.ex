defmodule ProtohackerElixir.Generic.Challenge do
  defmacro __using__(_) do
    quote do
      @behaviour ProtohackerElixir.Generic.Challenge
      require Logger

      def start_link(socket) do
        receive do
          :socket_transferred -> main_loop(socket)
          e -> Logger.debug("Error: #{inspect(e)}")
        end
      end
    end
  end

  @callback main_loop(:gen_tcp.socket()) :: any()

  @callback handle_connection(:gen_tcp.socket()) :: any()
end
