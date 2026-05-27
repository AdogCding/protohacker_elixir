# 1. The Router
defmodule ProtohackerElixir.Web.Router do
  use Phoenix.Router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug(:fetch_session)
  end

  scope "/" do
    pipe_through(:browser)
    live_dashboard("/dashboard")
  end
end

# 2. The Endpoint (Web Server)
defmodule ProtohackerElixir.Web.Endpoint do
  use Phoenix.Endpoint, otp_app: :protohacker_elixir

  # The dashboard requires a session to work securely
  plug(Plug.Session,
    store: :cookie,
    key: "_protohacker_key",
    signing_salt: "some_salt"
  )

  plug(ProtohackerElixir.Web.Router)
end
