defmodule PostgresqlAdapters.User.GettingById do
  alias Core.User.Ports.Getter
  alias Core.User.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        with query <- "SELECT * FROM users WHERE id = $1",
             {:ok, q} <- Postgrex.prepare(connection, "", query),
             {:ok, _, result} <- Postgrex.execute(connection, q, [id]),
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
          {:error, e} -> Exception.new(e.message)
        end

      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения пользователя")
  end
end
