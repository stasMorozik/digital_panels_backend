defmodule User.FakeAdapters.Inserting do
  alias Core.User.Ports.Transformer

  @behaviour Transformer

  alias Core.User.Entity

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
      fn -> :mnesia.write({:users, id, email, name, surname, created, updated}) end
    ) do
      {:atomic, :ok} -> {:ok, true}
      {:aborted, _} -> {:error, "Пользователь уже существует"}
    end
  end
end