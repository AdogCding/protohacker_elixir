defmodule ProtohackerElixir.StrangeDb.DbCmdHandler do
  alias ProtohackerElixir.StrangeDb.DbCmd

  def handle_cmd(input) do
    case String.split(input, "=", parts: 2) do
      [key, value] -> %DbCmd{cmd: :insert, key: key, value: value}
      [key] -> %DbCmd{cmd: :retrieve, key: key}
    end
  end
end
