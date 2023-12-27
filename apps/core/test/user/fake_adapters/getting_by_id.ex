defmodule User.FakeAdapters.GettingById do
  alias Core.User.Ports.Getter

  @behaviour Getter

  alias Core.User.Entity

  @impl Getter
  def get(id) do
    case :mnesia.transaction(fn -> :mnesia.index_read(
      :users, UUID.binary_to_string!(id), :id
    ) end) do
      {:atomic, list_users} -> 
        case length(list_users) > 0 do
          false -> {:error, "Пользователь не найден"}
          true -> 
            [user | _] = list_users

            {:users, id, email, name, surname, created, updated} = user

            {:ok, %Entity{
              id: id,
              email: email,
              name: name,
              surname: surname,
              created: created,
              updated: updated
            }}
        end
      {:aborted, _} -> {:error, "Пользователь не найден"}
    end
  end
end