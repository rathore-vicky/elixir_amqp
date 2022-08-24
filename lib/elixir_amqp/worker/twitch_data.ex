defmodule ElixirAMQP.Worker.TwitchData do
  @moduledoc false
  use GenServer
  use AMQP

  alias ElixirAMQP.ConnectionManager
  alias ElixirAMQP.Twitches

  require Logger

  @exchange "twitch_exchange"
  @queue "twitchdata_queue"
  @queue_error "#{@queue}_error"

  @fields [
    :channel,
    :watch_time,
    :stream_time,
    :peak_viewers,
    :avg_viewers,
    :followers,
    :followers_gained,
    :views_gained,
    :partnered,
    :mature,
    :language
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def channel_available(chan) do
    GenServer.cast(__MODULE__, {:channel_available, chan})
  end

  def init(_opts) do
    ConnectionManager.request_channel(__MODULE__)

    {:ok, %{chan: nil, consumer_tag: nil}}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, state) do
    Logger.info("Process registered: basic_consume_ok for consumer_tag #{consumer_tag}")

    {:noreply, %{state | consumer_tag: consumer_tag}}
  end

  # Sent by the broker when the consumer is unexpectedly cancelled (such as after a queue deletion)
  def handle_info({:basic_cancel, %{consumer_tag: _consumer_tag}}, state) do
    {:stop, :normal, state}
  end

  # Confirmation sent by the broker to the consumer process after a Basic.cancel
  def handle_info({:basic_cancel_ok, %{consumer_tag: _consumer_tag}}, state) do
    {:noreply, state}
  end

  def handle_info(
        {:basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}},
        state
      ) do
    # You might want to run payload consumption in separate Tasks in production
    consume(state.chan, tag, redelivered, payload)
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("Unhandled message received msg: #{inspect(msg)}")
    {:noreply, state}
  end

  def handle_cast({:channel_available, chan}, state) do
    Logger.info("Channel available for process: #{__MODULE__}")
    setup_queue(chan)

    {:ok, _consumer_tag} = Basic.consume(chan, @queue)
    {:noreply, %{state | chan: chan}}
  end

  defp setup_queue(chan) do
    {:ok, _} = Queue.declare(chan, @queue_error, durable: true)

    # Messages that cannot be delivered to any consumer in the main queue will be routed to the error queue
    {:ok, _} =
      Queue.declare(chan, @queue,
        durable: true,
        arguments: [
          {"x-dead-letter-exchange", :longstr, ""},
          {"x-dead-letter-routing-key", :longstr, @queue_error}
        ]
      )

    :ok = Exchange.topic(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, @queue, @exchange)
  end

  defp consume(_channel, _tag, _redelivered, payload) do
    [
      _channel,
      _watch_time,
      _stream_time,
      _peak_viewers,
      _avg_viewers,
      _followers,
      _followers_gained,
      _views_gained,
      _partnered,
      _mature,
      _language
    ] = data = String.split(payload, ",")

    {:ok, _struct} = insert_data(data)
    # :ok = Basic.ack channel, tag
    :ok
  rescue
    # Requeue unless it's a redelivered message.
    # This means we will retry consuming a message once in case of exception
    # before we give up and have it moved to the error queue
    #
    # You might also want to catch :exit signal in production code.
    # Make sure you call ack, nack or reject otherwise consumer will stop
    # receiving messages.
    _exception ->
      # :ok = Basic.reject channel, tag, requeue: not redelivered
      # Logger.debug("Exception raised #{inspect(exception)}")
      :ok
  end

  defp insert_data(data) do
    @fields
    |> Enum.zip(data)
    |> Map.new()
    |> Twitches.create_twitch()
  end
end
