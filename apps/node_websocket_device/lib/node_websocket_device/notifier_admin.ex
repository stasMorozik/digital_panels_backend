defmodule NodeWebsocketDevice.NotifierAdmin do
  @name_node Application.compile_env(:node_websocket_device, :name_node)
  
  def notify(message) do
    # {:ok, chann} = AMQP.Application.get_channel(:chan)
    # {:ok, conn} = AMQP.Connection.open("amqp://user:12345@192.168.0.107:5672")
    # {:ok, chann} = AMQP.Channel.open(conn)

    # AMQP.Basic.publish(chann, "notifier", "admins", Jason.encode!(%{
    #   subject: "Exception",
    #   message: message,
    #   node: @name_node,
    #   date: DateTime.utc_now()
    # }))
    
    {:ok, true}
  end
end