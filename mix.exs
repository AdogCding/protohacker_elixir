defmodule ProtohackerElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :protohacker_elixir,
      version: "0.1.0",
      elixir: "~> 1.19",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ProtohackerElixir.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.4"},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:plug_cowboy, "~> 2.5"},
      {:phoenix, "~> 1.7"},
      {:phoenix_live_dashboard, "~> 0.8.0"}
    ]
  end

  defp aliases() do
    [
      smoke_test: &start_smoke_test/1,
      prime_time: &start_prime_time/1,
      means_to_an_end: &start_means_to_an_end/1,
      budget_chat: &start_budget_chat/1,
      unusual_database_program: &start_unusual_database_program/1
    ]
  end

  defp start_smoke_test(_arg) do
    # <--- Add this so you can see your logs!
    Logger.configure(level: :debug)
    Mix.Task.run("app.start")

    spec =
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server,
         port: 10_001,
         challenge: ProtohackerElixir.Echo.Worker,
         task_type: :task,
         socket_opts: [
           :binary,
           packet: :line,
           active: false,
           reuseaddr: true
         ]},
        id: :echo
      )

    {:ok, _pid} = Supervisor.start_child(ProtohackerElixir.Supervisor, spec)
    System.no_halt(true)
  end

  defp start_prime_time(_) do
    Mix.Task.run("app.start")
    Logger.configure(level: :debug)

    spec =
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server,
         port: 10_002,
         challenge: ProtohackerElixir.Prime.Worker,
         task_type: :task,
         socket_opts: [
           :binary,
           :inet,
           packet: :line,
           active: false,
           buffer: 1024 * 1024,
           reuseaddr: true
         ]},
        id: :prime
      )

    {:ok, _pid} = Supervisor.start_child(ProtohackerElixir.Supervisor, spec)
    System.no_halt(true)
  end

  defp start_means_to_an_end(_) do
    Mix.Task.run("app.start")

    spec =
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server,
         port: 10_003,
         challenge: ProtohackerElixir.Price.Worker,
         task_type: :task,
         socket_opts: [
           :binary,
           :inet,
           active: false,
           reuseaddr: true
         ]},
        id: :price
      )

    {:ok, _pid} = Supervisor.start_child(ProtohackerElixir.Supervisor, spec)
    System.no_halt(true)
  end

  defp start_budget_chat(_) do
    Mix.Task.run("app.start")

    spec =
      Supervisor.child_spec(
        {ProtohackerElixir.Generic.Server,
         port: 10_004,
         challenge: ProtohackerElixir.Budget.Client,
         task_type: :dynamic,
         socket_opts: [
           :binary,
           packet: :line,
           active: false,
           reuseaddr: true
         ]},
        id: :budget_client
      )

    {:ok, _pid} = Supervisor.start_link([spec], strategy: :one_for_one)
    System.no_halt(true)
  end

  defp start_unusual_database_program(_) do
    Mix.Task.run("app.start")
    # DBAcceptor已经是GenServer了，不需要实现child_spec
    children = [
      {ProtohackerElixir.StrangeDb.DbAcceptor, [port: 10_005]},
      {ProtohackerElixir.StrangeDb.DbServer, [verion: "Keyang's 2026"]}
    ]

    {:ok, _pid} =
      Supervisor.start_link(children, strategy: :one_for_one)

    System.no_halt(true)
  end

  defp start_mob_in_the_middle() do
    Mix.Task.run("app.start")

    spec =
      Supervisor.child_spec()

    {:ok, _pid} = Supervisor.start_link([spec], strategy: :one_for_one)
    System.no_halt(true)
  end
end
