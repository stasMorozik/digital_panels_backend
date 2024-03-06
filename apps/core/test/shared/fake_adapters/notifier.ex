defmodule Shared.FakeAdapters.Notifier do
  alias Core.Shared.Ports.Notifier
  
  @behaviour Notifier

  @impl Notifier
  def notify(%Core.Shared.Types.Notification{
    to: to,
    from: from,
    subject: subject,
    message: message
  }) do
    IO.inspect("to - #{to}")
    IO.inspect("from - #{from}")
    IO.inspect("subject - #{subject}")
    IO.inspect("message - #{message}")
    
    {:ok, true}
  end

  def notify(_) do
    {:error, "Не валидные данняе для отрпавки уведомления"}
  end
end