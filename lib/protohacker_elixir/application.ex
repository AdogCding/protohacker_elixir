defmodule ProtohackerElixir.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: ProtohackerElixir.Generic.TaskSupervisor},
      {DynamicSupervisor, name: ProtohackerElixir.Generic.DynamicSupervisor},
      {ProtohackerElixir.StrangeDb.DbServer, version: "1.0.0"},
      {ProtohackerElixir.StrangeDb.DbAcceptor, port: 10_001}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProtohackerElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
