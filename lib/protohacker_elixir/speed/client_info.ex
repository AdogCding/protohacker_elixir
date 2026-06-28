defmodule ProtohackerElixir.Speed.ClientInfo do
  @enforce_keys [:socket, :pid, :heartbeat_interval]
  defstruct [:socket, :pid, :heartbeat_interval, role: nil]

  @type t :: %__MODULE__{
          socket: :gen_tcp.socket(),
          pid: pid(),
          heartbeat_interval: boolean(),
          role: :ticket_dispather | :camera | nil
        }
end
