defmodule ProtohackerElixir.StrangeDb.DbAcceptorData do
  defstruct socket: nil

  @type t :: %__MODULE__{
          socket: :gen_udp.socket() | nil
        }
end
