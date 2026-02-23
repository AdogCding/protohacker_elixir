defmodule ProtohackerElixir.Price.Worker do
  @moduledoc false
  alias ProtohackerElixir.Price.MeanQuery
  alias ProtohackerElixir.Price.PriceData
  use ProtohackerElixir.Generic.SimpleChallenge

  def main_loop(socket, prices) do
    case :gen_tcp.recv(socket, 9, 100_000) do
      {:ok, data} ->
        case handle_bytes(data) do
          {:I, price} ->
            Logger.debug("insert #{inspect(price)}")
            main_loop(socket, [price | prices])

          {:Q, query} ->
            res = search_period(query, prices)
            :gen_tcp.send(socket, <<res::big-integer-size(32)>>)
            Logger.debug("query #{inspect(query)}")
            main_loop(socket, prices)

          {:error, reason} ->
            reason
        end

      {:error, reason} ->
        Logger.error("Error: #{reason}")
    end
  end

  @spec search_period(MeanQuery.t(), list(PriceData.t())) :: integer()
  def search_period(%MeanQuery{mintime: min_time, maxtime: max_time}, data_list) do
    matched_data =
      Enum.filter(data_list, fn d ->
        d.timestamp >= min_time and d.timestamp <= max_time
      end)

    sum = Enum.sum_by(matched_data, fn d -> d.price end)
    len_of_matched_data = length(matched_data)

    if len_of_matched_data == 0 do
      0
    else
      div(sum, len_of_matched_data)
    end
  end

  @spec handle_bytes(binary()) :: {:I, PriceData.t()} | {:Q, MeanQuery.t()} | {:error, String.t()}
  def handle_bytes(data) do
    case data do
      <<?I, timestamp::signed-32, price::signed-32>> ->
        {:I,
         %PriceData{
           message_type: :insert,
           timestamp: timestamp,
           price: price
         }}

      <<?Q, mintime::signed-32, maxtime::signed-32>> ->
        {
          :Q,
          %MeanQuery{
            mintime: mintime,
            maxtime: maxtime
          }
        }

      _ ->
        {
          :error,
          "Error"
        }
    end
  end
end
