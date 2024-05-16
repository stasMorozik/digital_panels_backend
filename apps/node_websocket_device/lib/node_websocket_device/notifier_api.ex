defmodule NodeWebsocketDevice.NotifierApi do  
  def notify(%{id: id, is_active: is_active}) do
    {:ok, chann} = AMQP.Application.get_channel(:chann)

    AMQP.Basic.publish(chann, "api", "device", Jason.encode!(%{
      id: id, 
      is_active: is_active
    }))
    
    {:ok, true}
  end
end