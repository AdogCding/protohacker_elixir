defmodule ProtohackerElixir.StrangeDb.DbCmd do
  defstruct cmd: nil, key: nil, value: nil

  @type t :: %__MODULE__{
          cmd: :insert | :retrieve,
          key: String.t(),
          value: String.t() | nil
        }
end
