# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir_amqp,
  ecto_repos: [ElixirAMQP.Repo],
  generators: [binary_id: true]

config :elixir_amqp, ElixirAMQP.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "postgres",
  port: 5432,
  pool_size: 20,
  log: false

# Configures the endpoint
config :elixir_amqp, ElixirAMQPWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "h3KYFME33rqqu37CkF5+KAW30YpvXhJCBamAQ5c5nFfWx3s6Q06Fm/fPz/GsBZdm",
  render_errors: [view: ElixirAMQPWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: ElixirAMQP.PubSub,
  live_view: [signing_salt: "Gcsa2GJc"]

config :elixir_amqp, :rabbitmq_config, url: "amqp://guest:guest@rabbitmq"

config :elixir_amqp, :redis_config, url: "redis://redis:6379"

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :elixir_amqp, :csv_file_and_exchange,
  list: [
    {"./priv/data/dielectron.csv", "dielectron_exchange"},
    {"./priv/data/memegenerator.csv", "meme_exchange"},
    {"./priv/data/twitchdata-update.csv", "twitch_exchange"}
  ],
  dielectron: [{"./priv/data/dielectron.csv", "dielectron_exchange"}],
  memegenerator: [{"./priv/data/memegenerator.csv", "meme_exchange"}],
  twitchdata: [{"./priv/data/twitchdata-update.csv", "twitch_exchange"}]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
