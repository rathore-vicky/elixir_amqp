defmodule ElixirAMQP.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      ElixirAMQP.Repo,
      # Start the Telemetry supervisor
      ElixirAMQPWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: ElixirAMQP.PubSub},
      # Start the Endpoint (http/https)
      ElixirAMQPWeb.Endpoint,

      # Start a worker by calling: ElixirAMQP.Worker.start_link(arg)
      # {ElixirAMQP.Worker, arg}
      {ElixirAMQP.ConnectionManager, []},
      {ElixirAMQP.Worker.DiElectron, []},
      {ElixirAMQP.Worker.MemeGenerator, []},
      {ElixirAMQP.Worker.TwitchData, []},
      ElixirAMQP.Redix
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirAMQP.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    ElixirAMQPWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end