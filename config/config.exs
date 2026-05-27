import Config

# Configure the minimal Phoenix Endpoint
config :protohacker_elixir, ProtohackerElixir.Web.Endpoint,
  http: [port: 4000],
  server: true,
  secret_key_base: String.duplicate("a", 64),
  live_view: [signing_salt: "super_secret_salt"],
  pubsub_server: ProtohackerElixir.PubSub
