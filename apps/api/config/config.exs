import Config

config :api, ApiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    view: ApiWeb.ErrorView,
    accepts: ~w(json),
    layout: false
  ],
  pubsub_server: Api.PubSub,
  live_view: [signing_salt: "xgSq32lf"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
