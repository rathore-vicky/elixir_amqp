defmodule ElixirAMQP.Redix do
  @moduledoc """
    This module handles connections related to Redis.
  """

  @pool_size 5

  def get(key) do
    case command(["GET", key]) do
      {:ok, nil} ->
        {:ok, nil}

      {:ok, value} ->
        {:ok, :erlang.binary_to_term(value)}
    end
  end

  def set(key, value) do
    command(["SET", key, :erlang.term_to_binary(value)])
  end

  def child_spec(_args) do
    # Specs for the Redix connections.
    redis_url = Application.get_env(:elixir_amqp, :redis_config)[:url]

    children =
      for index <- 0..(@pool_size - 1) do
        Supervisor.child_spec({Redix, {redis_url, [name: :"redix_#{index}"]}}, id: {Redix, index})
      end

    # Spec for the supervisor that will supervise the Redix connections.
    %{
      id: RedixSupervisor,
      type: :supervisor,
      start: {Supervisor, :start_link, [children, [strategy: :one_for_one]]}
    }
  end

  defp command(command) do
    Redix.command(:"redix_#{random_index()}", command)
  end

  defp random_index() do
    Enum.random(0..(@pool_size - 1))
  end
end
