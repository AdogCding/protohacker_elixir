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
      {Phoenix.PubSub, name: ProtohackerElixir.PubSub},
      ProtohackerElixir.Web.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ProtohackerElixir.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
