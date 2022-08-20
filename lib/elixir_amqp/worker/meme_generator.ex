defmodule ElixirAMQP.Worker.MemeGenerator do
  use GenServer
  use AMQP

  alias ElixirAMQP.ConnectionManager
  alias ElixirAMQP.Memes

  require Logger

  @exchange "memegenerator_exchange"
  @queue "memegenerator_queue"
  @queue_error "#{@queue}_error"

  @fields [
    :id,
    :archived_url,
    :base_name,
    :page_url,
    :md5_hash,
    :file_size,
    :alternate_text
  ]

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def channel_available(chan) do
    GenServer.cast(__MODULE__, {:channel_available, chan})
  end

  def init(_opts) do
    # {:ok, conn} = Connection.open("amqp://guest:guest@localhost")
    # {:ok, chan} = Channel.open(conn)
    # setup_queue(chan)

    # # Limit unacknowledged messages to 10
    # # :ok = Basic.qos(chan, prefetch_count: 10)
    # # Register the GenServer process as a consumer
    # {:ok, _consumer_tag} = Basic.consume(chan, @queue, [no_wait: true, no_ack: true])
    ConnectionManager.request_channel(__MODULE__)
    {:ok, %{chan: nil, consumer_tag: nil}}
  end

  # Confirmation sent by the broker after registering this process as a consumer
  def handle_info({:basic_consume_ok, %{consumer_tag: consumer_tag}}, state) do
    Logger.info("Process registered: basic_consume_ok for consumer_tag #{consumer_tag}")
    {:noreply, %{state | consumer_tag: consumer_tag}}
  end

  def handle_info({:basic_consume_ok, _}, state) do
    Logger.info("Process registered: basic_consume_ok for consumer_tag #{state}")
    {:noreply, state}
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

  def handle_info(
        {:basic_deliver, payload, _meta},
        state
      ) do
    # You might want to run payload consumption in separate Tasks in production
    spawn(fn -> consume(state.chan, nil, false, payload) end)
    :ok
    {:noreply, state}
  end

  def handle_info(msg, state) do
    Logger.info("Unhandled message received msg: #{inspect(msg)}")
    {:noreply, state}
  end

  def handle_cast({:channel_available, chan}, state) do
    Logger.info("Channel available for process: #{__MODULE__}")
    setup_queue(chan)

    {:ok, _consumer_tag} = Basic.consume(chan, @queue, nil, no_ack: true)
    {:noreply, %{state | chan: chan}}
  end

  def handle_call(_msg, _from, state) do
    {:reply, :ok, state}
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
      _id,
      _archived_url,
      _base_name,
      _page_url,
      _md5_hash,
      _file_size,
      _alternate_text
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
    exception ->
      # :ok = Basic.reject channel, tag, requeue: not redelivered
      Logger.debug("Exception raised #{inspect(exception)}")
      :ok
  end

  defp insert_data(data) do
    @fields
    |> Enum.zip(data)
    |> Map.new()
    |> Memes.create_meme()
  end
end
