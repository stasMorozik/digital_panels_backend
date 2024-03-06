defmodule Api.NotifierDev do
  require Logger
  alias Core.Shared.Ports.Notifier

  @node_notifier Application.compile_env(:api, :node_notifier)
  @name_notifier Application.compile_env(:api, :name_notifier)

  @behaviour Notifier

  @impl Notifier
  def notify(%{
    to: to,
    from: from,
    subject: subject,
    message: message
  }) do
    Process.send({@node_notifier, @name_notifier}, {:for_developer, %{
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