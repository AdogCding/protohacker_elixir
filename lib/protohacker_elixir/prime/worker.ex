defmodule ProtohackerElixir.Prime.Worker do
  use ProtohackerElixir.Generic.Challenge

  @impl true
  def main_loop(socket) do
    case parse_request(socket) do
      {:ok, json} ->
        case json do
          {:ok, %{"method" => "isPrime", "number" => num}} when is_number(num) ->
            is_prime = prime?(num)
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

  def prime?(n) when is_integer(n) and n < 2, do: false
  def prime?(2), do: true

  def prime?(n) when is_integer(n) do
    not Enum.any?(3..trunc(:math.sqrt(n)), fn x -> rem(n, x) == 0 end)
  end

  def prime?(_), do: false
end
