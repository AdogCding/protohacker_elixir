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
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server, port: 10001, challenge: ProtohackerElixir.Echo.Worker},
        id: :echo
      ),
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server,
         port: 10002,
         challenge: ProtohackerElixir.Prime.Worker,
         socket_opts: [
           :binary,
           packet: :line,
           active: false,
           buffer: 1024 * 1024,
           reuseaddr: true
         ]},
        id: :prime
      ),
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server,
         port: 10003,
         challenge: ProtohackerElixir.Price.Worker,
         socket_opts: [
           :binary,
           active: false,
           reuseaddr: true
         ]},
        id: :price
      ),
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server,
         port: 10004,
         challenge: ProtohackerElixir.Budget.Client,
         task_type: :dynamic,
         socket_opts: [
           :binary,
           active: false,
           reuseaddr: true
         ]},
        id: :budget_client
      )
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProtohackerElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
