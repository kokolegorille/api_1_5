# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :api,
  ecto_repos: [Api.Repo]

config :api, Api.Repo, migration_timestamps: [type: :utc_datetime]

# Configures the endpoint
config :api, ApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "pZAYQcvQn9JJAdBglPqY65v98f0Mnpro+36RBfd8Dd16fMfl+LbROaYs4SvPH6bB",
  render_errors: [view: ApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: Api.PubSub,
  live_view: [signing_salt: "+u1c3coi"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
