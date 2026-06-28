defmodule ProtohackerElixir.Speed.Client.ClientState do
  @enforce_keys [:role, :heartbeat_interval, :data, :socket, :pid]
  defstruct [:pid, :role, :heartbeat_interval, :data, :socket, :mile, :limit, :road, :roads]

  @type t :: %__MODULE__{
          role: :camera,
          heartbeat_interval: nil | non_neg_integer(),
          data: binary(),
          pid: pid(),
          socket: :gen_tcp.socket(),
          mile: nil | non_neg_integer(),
          limit: nil | non_neg_integer(),
          road: nil | non_neg_integer(),
          roads: nil | list(non_neg_integer())
        }
end
