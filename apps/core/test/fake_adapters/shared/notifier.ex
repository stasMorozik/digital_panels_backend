defmodule FakeAdapters.Shared.Notifier do
  alias Core.Shared.Ports.Notifier

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Notifier

  @impl Notifier
  def notify(%{
    to: to,
    from: from,
    subject: subject,
    message: message
  }) do
    IO.inspect("to - #{to}")
    IO.inspect("from - #{from}")
    IO.inspect("subject - #{subject}")
    IO.inspect("message - #{message}")
    Success.new(true)
  end

  def transform(_) do
    Error.new("Не валидные данняе для вставки")
  end
end
