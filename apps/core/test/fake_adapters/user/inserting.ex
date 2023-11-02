defmodule FakeAdapters.User.Inserting do
  alias Core.User.Ports.Transformer
  alias Core.User.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{
    id: id,
    email: email,
    name: name,
    surname: surname,
    created: created,
    updated: updated
  }) do
    case :mnesia.transaction(
      fn -> :mnesia.write({:users, name, id, email, surname, created, updated}) end
    ) do
      {:atomic, :ok} -> Success.new(true)
      {:aborted, _} -> Error.new("Пользователь уже существует")
    end
  end

  def transform(_) do
    Error.new("Не возможно занести запись в хранилище данных, не валидный пользователь")
  end
end
