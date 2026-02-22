defmodule ProtohackerElixir.Budget.User do
  defstruct name: nil, id: nil, pid: nil

  @type t :: %__MODULE__{
          name: String.t(),
          id: String.t(),
          pid: pid()
        }

  def valid_name?(name) do
    name |> String.length() > 0 and String.match?(name, ~r/^[a-zA-Z0-9]+$/)
  end
end
