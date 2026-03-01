defmodule ProtohackerElixir.StrangeDb.DbCmdHandler do
  alias ProtohackerElixir.StrangeDb.DbCmd

  def parse_cmd(input) do
    cmd =
      case String.split(input, "=", parts: 2) do
        [key, value] -> %DbCmd{cmd: :insert, key: key, value: value}
        [key] -> %DbCmd{cmd: :retrieve, key: key}
        _ -> nil
      end

    case cmd do
      nil -> {:error, nil}
      cmd -> {:ok, cmd}
    end
  end
end
