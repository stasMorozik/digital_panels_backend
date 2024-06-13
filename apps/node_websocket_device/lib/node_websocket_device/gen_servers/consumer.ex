defmodule NodeWebsocketDevice.GenServers.Consumer do
  use GenServer
  use AMQP

  @exchange    "websocket_device"
  @queue       "content_change"

  alias NodeWebsocketDevice.GenServers.Websocket
  alias NodeWebsocketDevice.Logger, as: AppLogger

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  def init(_opts) do
    {:ok, chann} = AMQP.Application.get_channel(:chann)

    :ok = Queue.bind(chann, @queue, @exchange)
    
    :ok = Basic.qos(chann, prefetch_count: 10)

    {:ok, _} = Basic.consume(chann, @queue)

    {:ok, chann}
  end

  def handle_info({:basic_consume_ok, %{consumer_tag: _}}, chann) do
    {:noreply, chann}
  end

  def handle_info({:basic_cancel, %{consumer_tag: _}}, chann) do
    {:stop, :normal, chann}
  end
  
  def handle_info({:basic_cancel_ok, %{consumer_tag: _}}, chann) do
    {:noreply, chann}
  end

  def handle_info({:basic_deliver, payload, %{delivery_tag: tag, redelivered: _}}, chann) do
    case Jason.decode(payload) do
      {:ok, %{"group_id" => group_id}} -> 
        Websocket.broadcast(group_id)
      {:error, _} -> 
        AppLogger.exception("Не валидный json для публикации на устройсвта")
      _ ->
        AppLogger.exception("Не валидные данные для публикации на устройсвта")
    end

    :ok = Basic.ack(chann, tag)

    {:noreply, chann}
  end
end