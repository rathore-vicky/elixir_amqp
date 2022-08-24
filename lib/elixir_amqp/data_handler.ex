defmodule ElixirAMQP.DataHandler do
  @moduledoc """
    This module is mediator between External APIs and Internal functions.
  """
  use AMQP

  alias ElixirAMQP.{DiElectrons, Memes, Twitches}
  alias ElixirAMQP.Redix

  @max_concurrency System.schedulers_online()

  @spec dispatch_data(csv_files :: String.t()) :: :ok
  def dispatch_data(csv_files \\ Application.get_env(:elixir_amqp, :csv_file_and_exchange)[:list]) do
    {:ok, conn} = Connection.open(Application.get_env(:elixir_amqp, :rabbitmq_config)[:url])
    {:ok, channel} = Channel.open(conn)

    csv_files
    |> Task.async_stream(&read_file(&1, channel),
      ordered: false,
      max_concurrency: @max_concurrency
    )
    |> Stream.run()
  end

  @spec get_or_store(topic :: String.t(), pagination_params :: map()) ::
          {:ok, Scrivener.Page.t()} | {:error, any()}
  def get_or_store(topic, pagination_params) when pagination_params == %{},
    do: get_or_store(topic, %{page: 1, page_size: 10})

  def get_or_store(topic, %{page: page, page_size: page_size} = pagination_params) do
    key = get_key([topic, page, page_size])

    case Redix.get(key) do
      {:ok, nil} ->
        case list_with_pagination(topic, pagination_params) do
          {:error, _reason} = error ->
            error

          %Scrivener.Page{entries: entries} = page when entries == [] ->
            {:ok, page}

          page ->
            {:ok, "OK"} = Redix.set(key, page.entries)
            get_or_store(topic, pagination_params)
        end

      {:ok, entries} ->
        {:ok, %Scrivener.Page{entries: entries, page_number: page, page_size: page_size}}
    end
  end

  defp list_with_pagination(:memes, pagination_params) do
    Memes.list_with_pagination(pagination_params)
  end

  defp list_with_pagination(:twitches, pagination_params) do
    Twitches.list_with_pagination(pagination_params)
  end

  defp list_with_pagination(:dielectrons, pagination_params) do
    DiElectrons.list_with_pagination(pagination_params)
  end

  defp read_file({filename, exchange}, channel) do
    filename
    |> File.stream!()
    |> Stream.drop(1)
    |> Stream.map(&String.trim(&1, "\n"))
    |> Enum.each(fn symbol ->
      write_queue(channel, exchange, symbol)
    end)
  end

  defp write_queue(channel, exchange, symbol) do
    AMQP.Basic.publish(channel, exchange, "", symbol)
  end

  defp get_key(list), do: Enum.join(list, "_")
end
