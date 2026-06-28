defmodule ProtohackerElixir.Generic.SimpleChallenge do
  @moduledoc false
  defmacro __using__(_) do
    quote do
      @behaviour ProtohackerElixir.Generic.SimpleChallenge
      require Logger

      @impl true
      def main_loop(socket) do
        main_loop(socket, [])
      end

      @impl true
      def handle_connection(socket) do
        start_link(socket)
      end

      def start_link(socket) do
        receive do
          :socket_transferred -> main_loop(socket)
          e -> Logger.debug("Error: #{inspect(e)}")
        end
      end
    end
  end

  @callback main_loop(:gen_tcp.socket()) :: any()

  @callback main_loop(:gen_tcp.socket(), list()) :: any

  @callback handle_connection(:gen_tcp.socket()) :: any()
end
