defmodule PostgresqlAdapters.User.Inserting do
  alias Core.User.Ports.Transformer
  alias Core.User.Entity

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        query = "
          INSERT INTO users (
            id, email, name, surname, created, updated
          ) VALUES(
            $1, $2, $3, $4, $5, $6
          )
        "

        with {:ok, q} <- Postgrex.prepare(connection, "", query),
             data <- [
              UUID.string_to_binary!(user.id), 
              user.email, 
              user.name, 
              user.surname, 
              user.created, 
              user.updated
             ],
             {:ok, _, _} <- Postgrex.execute(connection, q, data) do
          {:ok, true}
        else
          {:error, %Postgrex.Error{postgres: %{pg_code: "23505"}}} -> {:error, "Пользователь уже существует"}
          {:error, e} -> {:exception, e.message}
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def transform(_) do
    {:error, "Не валидные данные для занесения пользователя в базу данных"}
  end
end
