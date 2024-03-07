defmodule NodeApi.NotifierUser do
  require Logger
  alias Core.Shared.Ports.Notifier

  @where {
    Application.compile_env(:node_api, :name_process_notifier), 
    Application.compile_env(:node_api, :name_node_notifier)
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
    {:error, "Не валидные данные для отправки сообщение на электронную почту"}
  end
end