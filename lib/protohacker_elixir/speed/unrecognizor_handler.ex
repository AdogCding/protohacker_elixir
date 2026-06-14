defmodule ProtohackerElixir.Speed.UnrecognizorHandler do
  alias ProtohackerElixir.Speed.DataType

  # 递归解析数据流
  @spec process_data(binary()) :: Map.t()
  def process_data(data) do
    {msg, rest_bytes} =
      case DataType.parse(data) do
        {:ok, msg, rest_bytes} ->
          {msg, rest_bytes}

        {:error, :incomplete} ->
          {nil, data}

        {:error, :unknown_type} ->
          {nil, data}
      end

    %{}
  end
end
