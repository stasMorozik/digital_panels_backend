defmodule PostgresqlAdapters.User.Getting do
  alias Core.User.Ports.Getter
  alias Core.User.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Getter

  @impl Getter
  def get(email) when is_binary(email) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        with query <- "SELECT * FROM users WHERE email = $1",
             {:ok, q} <- Postgrex.prepare(connection, "", query),
             {:ok, _, result} <- Postgrex.execute(connection, q, [email]),
             true <- result.num_rows > 0,
             [ [id, email, name, surname, created, updated] ] <- result.rows do
             
          Success.new(%Entity{
            id: UUID.binary_to_string!(id),
            email: email,
            name: name,
            surname: surname,
            created: created,
            updated: updated
          })
        else
          false -> Error.new("Пользователь не найден")
          {:error, _} -> Error.new("Ошибка запроса к базе данных")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения пользователя")
  end
end
