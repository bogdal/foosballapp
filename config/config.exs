# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :foosball,
  ecto_repos: [Foosball.Repo]

# Configures the endpoint
config :foosball, Foosball.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "He/cUPoEjxBZQSwVPeP8zkIn7F9vL5mXn+q2VHJGz1Gid/3mJHO+GhA3g0/JQbl3",
  render_errors: [view: Foosball.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Foosball.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
