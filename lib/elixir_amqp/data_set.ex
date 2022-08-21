defmodule ElixirAMQP.DataSet do
  @moduledoc false
  use AMQP

  alias ElixirAMQP.{DiElectrons, Memes, Twitches}
  alias ElixirAMQP.Redix

  @max_concurrency System.schedulers_online()

  @csv_files Application.get_env(:elixir_amqp, :csv_file_and_exchange)[:list]
  @url Application.get_env(:elixir_amqp, :rabbitmq_config)[:url]

  def dispatch_data(csv_files \\ @csv_files) do
    {:ok, conn} = Connection.open(@url)
    {:ok, channel} = Channel.open(conn)

    csv_files
    |> Task.async_stream(&read_file(&1, channel),
      ordered: false,
      max_concurrency: @max_concurrency
    )
    |> Stream.run()
  end

  def get_or_store(topic, pagination_params) when pagination_params == %{} do
    get_or_store(topic, %{page: 1, page_size: 10})
  end

  def get_or_store(topic, %{page: page, page_size: page_size} = pagination_params) do
    key = "#{topic}_#{page}_#{page_size}"

    case Redix.command(["GET", key]) do
      {:ok, nil} ->
        page = list_with_pagination(topic, pagination_params)
        {:ok, "OK"} = Redix.command(["SET", key, :erlang.term_to_binary(page.entries)])

        get_or_store(topic, pagination_params)

      {:ok, value} ->
        entries = :erlang.binary_to_term(value)
        %Scrivener.Page{entries: entries, page_number: page, page_size: page_size}
    end
  end

  defp list_with_pagination("memes", pagination_params) do
    Memes.list_with_pagination(pagination_params)
  end

  defp list_with_pagination("twitches", pagination_params) do
    Twitches.list_with_pagination(pagination_params)
  end

  defp list_with_pagination("dielectrons", pagination_params) do
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
end
