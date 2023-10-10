defmodule PostgresqlAdapters.User.GettingById do
  alias Core.User.Ports.Getter
  alias Core.User.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        query = Postgrex.prepare!(
          connection,
          "",
          "SELECT * FROM users WHERE id = $1"
        )

        case Postgrex.execute(connection, query, [UUID.string_to_binary!(id)]) do
          {:ok, _, result} ->
            with true <- result.num_rows > 0,
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
            end
          {:error, _} -> Error.new("Что то пошло не так")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения пользователя")
  end
end
