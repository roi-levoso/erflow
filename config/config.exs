# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :erflow,
  ecto_repos: [Erflow.Repo]

# Configures the endpoint
config :erflow, ErflowWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "tw5hc9rpiypfAMx9WKUqStb90V6oRttKMRBJxmxAMgCsPALHCs3QMfwUPh+VcMWK",
  render_errors: [view: ErflowWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Erflow.PubSub,
  live_view: [signing_salt: "W+J+v0njz+2gmfvJx9wxM19hloOlnvy2"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
