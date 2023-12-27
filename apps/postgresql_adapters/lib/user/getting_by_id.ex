defmodule PostgresqlAdapters.User.GettingById do
  alias Core.User.Ports.Getter
  alias Core.User.Entity

  alias PostgresqlAdapters.User.Mapper
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        with query <- "SELECT id, email, name, surname, created, updated FROM users WHERE id = $1",
             {:ok, result} <- Executor.execute(query, [id]),
             true <- result.num_rows > 0,
             [ row ] <- result.rows,
             [ id, email, name, surname, created, updated ] <- row do
          {:ok, %Entity{
            id: UUID.binary_to_string!(id),
            email: email,
            name: name,
            surname: surname,
            created: created,
            updated: updated
          }}
        else
          false -> {:error, "Пользователь не найден"}
          {:exception, message} -> {:exception, message}
        end

      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_) do
    {:error, "Не валидные данные для получения пользователя"}
  end
end
