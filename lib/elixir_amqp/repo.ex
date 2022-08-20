defmodule ElixirAMQP.Repo do
  use Ecto.Repo,
    otp_app: :elixir_amqp,
    adapter: Ecto.Adapters.Postgres

  use Scrivener, page_size: 30
end
