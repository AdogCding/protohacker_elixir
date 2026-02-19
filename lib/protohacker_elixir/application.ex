defmodule ProtohackerElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: ProtohackerElixir.Generic.TaskSupervisor},
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server, port: 10000, challenge: ProtohackerElixir.Echo.Worker},
        id: :echo
      ),
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server,
         port: 10001, challenge: ProtohackerElixir.Prime.Worker, socket_opts: [packet: :line]},
        id: :prime
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProtohackerElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
