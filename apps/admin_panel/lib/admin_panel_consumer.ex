defmodule AdminPanelConsumer do
  use GenServer
  use AMQP

  def start_link do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange    "devices_status_exchange"
  @queue       "devices_status_queue"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    amqp_user = Application.fetch_env!(:consumer, :user)
    amqp_password = Application.fetch_env!(:consumer, :password)
    amqp_host = Application.fetch_env!(:consumer, :host)

    {:ok, conn} = Connection.open(
      "amqp://#{amqp_user}:#{amqp_password}@#{amqp_host}"
    )

    {:ok, chan} = Channel.open(conn)
    
    setup_queue(chan)

    :ok = Basic.qos(chan, prefetch_count: 10)
    
    {:ok, _consumer_tag} = Basic.consume(chan, @queue)

    {:ok, chan}
  end

  def handle_info({
    :basic_consume_ok, %{consumer_tag: consumer_tag}
  }, chan) do
    {:noreply, chan}
  end

  def handle_info({
    :basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}
  }, chan) do
    {:noreply, chan}
  end

  defp setup_queue(chan) do
    {:ok, _} = Queue.declare(chan, @queue_error, durable: true)
    {:ok, _} = Queue.declare(
      chan, 
      @queue,
      durable: true,
      arguments: [
        {"x-dead-letter-exchange", :longstr, ""},
        {"x-dead-letter-routing-key", :longstr, @queue_error}
      ]
    )
    :ok = Exchange.fanout(chan, @exchange, durable: true)
    :ok = Queue.bind(chan, @queue, @exchange)
  end
end