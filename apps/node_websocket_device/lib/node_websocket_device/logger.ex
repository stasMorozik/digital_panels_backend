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
    {:ok, chann} = AMQP.Application.get_channel(:chann)

    data = %{
      message: message, 
      node: @name_node, 
      date: DateTime.utc_now()
    }

    AMQP.Basic.publish(chann, "logger", type, Jason.encode!(data))
  end
end