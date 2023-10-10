defmodule FakeAdapters.ConfirmationCode.Inserting do
  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{
    needle: needle,
    created: created,
    code: code,
    confirmed: confirmed
  }) do
    case :mnesia.transaction(
      fn -> :mnesia.write({:codes, needle, created, code, confirmed}) end
    ) do
      {:atomic, :ok} -> Success.new(true)
      {:aborted, _} -> Error.new("Код уже существует")
    end
  end

  def transform(_) do
    Error.new("Не возможно занести запись в хранилище данных, не валидный код подтверждения")
  end
end
