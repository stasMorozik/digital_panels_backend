defmodule AdminPanelConsumer do
  use GenServer
  use AMQP

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], [])
  end

  @exchange    "devices_status_exchange"
  @queue       "devices_status_queue"
  @queue_error "#{@queue}_error"

  def init(_opts) do
    amqp_user = Application.fetch_env!(:consumer, :user)
    amqp_password = Application.fetch_env!(:consumer, :password)
    amqp_host = Application.fetch_env!(:consumer, :host)

    {:ok, pid} = Connection.open(
      "amqp://#{amqp_user}:#{amqp_password}@#{amqp_host}"
    )

    :ets.insert(:connections, {"rabbitmq", "", pid})

    {:ok, chan} = Channel.open(pid)
    
    setup_queue(chan)
    
    {:ok, _consumer_tag} = Basic.consume(chan, @queue)

    {:ok, chan}
  end

  def handle_info({
    :basic_consume_ok, %{consumer_tag: consumer_tag}
  }, chan) do
    {:noreply, chan}
  end

  def handle_info({:basic_cancel, %{consumer_tag: consumer_tag}}, chan) do
    {:stop, :normal, chan}
  end

  def handle_info({:basic_cancel_ok, %{consumer_tag: consumer_tag}}, chan) do
    {:noreply, chan}
  end

  def handle_info({
    :basic_deliver, payload, %{delivery_tag: tag, redelivered: redelivered}
  }, chan) do
    with {:ok, decode_payload} <- Jason.decode(payload),
         {:ok, id} <- Map.fetch(decode_payload, "id"),
         {:ok, status} <- Map.fetch(decode_payload, "is_active"),
         true <- is_boolean(status),
         {:ok, _} <- UUID.info(id) do

      [{_, "", list}] = :ets.lookup(:admin_sockets, "pids")

      Enum.map(list, fn pid -> 
        if Process.alive?(pid) == true do
          send(pid, {:change_activity, %{id: id, is_active: status}})
        end
      end)

      {:noreply, chan}
    else
      {:error, _} -> {:noreply, chan}
      :error -> {:noreply, chan}
      false -> {:noreply, chan}
    end
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