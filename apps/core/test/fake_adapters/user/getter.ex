defmodule FakeAdapters.User.Getter do
  alias Core.User.Ports.Getter
  alias Core.User.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Getter

  @impl Getter
  def get(email) when is_binary(email) do
    case :mnesia.transaction(fn -> :mnesia.index_read(:users, email, :email) end) do
      {:atomic, list_users} ->
        if length(list_users) > 0 do

          [user | _] = list_users

          {:users, id, email, name, surname, created, updated} = user

          Success.new(%Entity{
            id: id,
            email: email,
            name: name,
            surname: surname,
            created: created,
            updated: updated
          })

        else
          Error.new("Пользователь не найден")
        end
      {:aborted, _} ->  Error.new("Пользователь не найден")
    end
  end

  def get(_) do
    Error.new("Не валидный адрес электронной почты")
  end
end
