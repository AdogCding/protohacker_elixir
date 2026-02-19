defmodule ProtohackerElixir.Prime.Worker do
  use ProtohackerElixir.Generic.Challenge
  alias ProtohackerElixir.Prime.Helper

  @impl true
  def main_loop(socket) do
    case parse_request(socket) do
      {:ok, json} ->
        case json do
          {:ok, %{"method" => "isPrime", "number" => num}} when is_number(num) ->
            is_prime = Helper.prime?(num)
            response = "#{Jason.encode!(%{"method" => "isPrime", "prime" => is_prime})}\n"
            :gen_tcp.send(socket, response)
            main_loop(socket)

          _ ->
            :gen_tcp.send(socket, Jason.encode!(%{"error" => "Invalid request"}))
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  def parse_request(socket) do
    case :gen_tcp.recv(socket, 0) do
      {:ok, line} ->
        {:ok, Jason.decode(line)}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
