defmodule NodeApi.Notifiers.Admin do
  @name_node Application.compile_env(:node_api, :name_node)
  
  def notify(message) do
    {:ok, chann} = AMQP.Application.get_channel(:chann)

    AMQP.Basic.publish(chann, "notifier", "admins", Jason.encode!(%{
      subject: "Exception",
      message: message,
      node: @name_node,
      date: DateTime.utc_now()
    }))
    
    {:ok, true}
  end
end