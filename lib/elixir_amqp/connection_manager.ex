defmodule ElixirAMQP.ConnectionManager do
  @moduledoc """
    This module handles connection to RabbitMQ.
  """
  use GenServer
  use AMQP

  require Logger

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def request_channel(consumer) do
    GenServer.cast(__MODULE__, {:chan_request, consumer})
  end

  def init(_args) do
    establish_new_connection()
  end

  defp establish_new_connection do
    case AMQP.Connection.open(Application.get_env(:elixir_amqp, :rabbitmq_config)[:url]) do
      {:ok, conn} ->
        Process.monitor(conn.pid)
        Logger.info("AMQP connection established")
        {:ok, {conn, %{}}}

      {:error, reason} ->
        Logger.error("failed for #{inspect(reason)}")
        :timer.sleep(5000)
        establish_new_connection()
    end
  end

  def handle_cast({:chan_request, consumer}, {conn, channel_mappings}) do
    Logger.info("Channel request received from : #{consumer}")

    new_mapping = store_channel_mapping(conn, consumer, channel_mappings)
    channel = Map.get(new_mapping, consumer)
    consumer.channel_available(channel)
    {:noreply, {conn, new_mapping}}
  end

  defp store_channel_mapping(conn, consumer, channel_mappings) do
    Map.put_new_lazy(channel_mappings, consumer, fn -> create_channel(conn) end)
  end

  defp create_channel(conn) do
    {:ok, chan} = Channel.open(conn)
    chan
  end

  def handle_info({:DOWN, _, :process, _pid, reason}, state) do
    Logger.error("RabbitMQ Down due to #{inspect(reason)}")

    # Killing each child on Rabbitmq disconnect
    supervisor_name = ElixirAMQP.Supervisor

    Enum.each(Supervisor.which_children(supervisor_name), fn {name, _, _, _} ->
      Supervisor.terminate_child(supervisor_name, name)
    end)

    {:stop, :normal, state}
  end
end
