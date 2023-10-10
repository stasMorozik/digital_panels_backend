defmodule FakeAdapters.ConfirmationCode.Creating do
  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{created: _, confirmed: _, code: _, needle: _}) do
    Success.new(true)
  end

  def transform(_) do
    Error.new("Не валидные данняе для вставки")
  end
end
