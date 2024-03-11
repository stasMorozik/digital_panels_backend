defmodule NotifierAdapters.SenderToUser do
  alias Core.Shared.Ports.Notifier

  @where {
    Application.compile_env(:notifier_adapters, :name_process), 
    Application.compile_env(:notifier_adapters, :name_node)
  }

  @behaviour Notifier

  @impl Notifier
  def notify(%{
    to: to,
    from: from,
    subject: subject,
    message: message
  }) do
    Process.send(@where, {:for_user, %{
      to: to,
      from: from,
      subject: subject,
      message: message
    }}, [:noconnect])

    {:ok, true}
  end

  def notify(_) do
    {:error, "Не валидные данные для отправки сообщения для ноды"}
  end
end