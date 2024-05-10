import Config

# Configures the endpoint
config :andromeda, AndromedaWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: AndromedaWeb.ErrorHTML, json: AndromedaWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Andromeda.PubSub,
  live_view: [signing_salt: "7I9j5e75"]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  andromeda: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
