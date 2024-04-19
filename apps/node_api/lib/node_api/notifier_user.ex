defmodule NodeApi.NotifierUser do
  alias Core.Shared.Ports.Notifier

  @behaviour Notifier

  @impl Notifier
  def notify(%{
    to: to,
    from: from,
    subject: subject,
    message: message
  }) do
    {:ok, chann} = AMQP.Application.get_channel(:chann)

    AMQP.Basic.publish(chann, "notifier", "users", Jason.encode!(%{
      to: to,
      from: from,
      subject: subject,
      message: message
    }))
    
    {:ok, true}
  end

  def notify(_) do
    {:error, "Не валидные данные для отправки сообщение на электронную почту"}
  end
end