defmodule ProtohackerElixir.StrangeDb.DbServerData do
  defstruct data: %{}, socket: nil

  @type string_map :: %{optional(String.t()) => String.t()}

  @type t :: %__MODULE__{
          data: string_map(),
          socket: :gen_udp.socket() | nil
        }
end
