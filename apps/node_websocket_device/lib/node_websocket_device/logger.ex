defmodule NodeWebsocketDevice.Logger do
  @name_node Application.compile_env(:node_websocket_device, :name_node)

  def exception(message) do
    log("exception", message)
  end

  def info(message) do
    log("info", message)
  end

  def error(message) do
    log("error", message)
  end

  defp log(type, message) do
    # {:ok, chann} = AMQP.Application.get_channel(:chan)
    r = AMQP.Connection.open("amqp://user:12345@192.168.0.107:5672")
    
    IO.inspect(r)
    # {:ok, chann} = AMQP.Channel.open(conn)

    data = %{
      message: message, 
      node: @name_node, 
      date: DateTime.utc_now()
    }

    IO.inspect(data)

    # AMQP.Basic.publish(chann, "logger", type, Jason.encode!(data))
  end
end