defmodule SmtpAdapters.Notifier do
  import Swoosh.Email

  alias Core.Shared.Ports.Notifier

  @behaviour Notifier

  @impl Notifier
  def notify(%{
    to: to,
    from: from,
    subject: subject,
    message: message
  }) do
    email = new()
      |> to(to)
      |> from({"System content manager", from})
      |> subject(subject)
      |> html_body(message)
      |> text_body(message)

    IO.inspect(email)

    case SmtpAdapters.Mailer.deliver(email) do
      {:ok, _} -> {:ok, true}
      _ -> {:error, "Не удалось отправить код подтверждения на вашу электронную почту"}
    end
  end

  def notify(_) do
    {:error, "Не валидные данные для отправки сообщение на электронную почту"}
  end
end
