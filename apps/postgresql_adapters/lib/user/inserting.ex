defmodule PostgresqlAdapters.User.Inserting do
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
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        query = "INSERT INTO users (id, email, name, surname, created, updated) VALUES($1, $2, $3, $4, $5, $6)"

        with {:ok, q} <- Postgrex.prepare(connection, "", query),
             data <- [UUID.string_to_binary!(id), email, name, surname, created, updated],
             {:ok, _, _} <- Postgrex.execute(connection, q, data) do
          Success.new(true)
        else
          {:error, _} -> Error.new("Ошибка запроса к базе данных")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def transform(_) do
    Error.new("Не валидные данные для занесения пользователя в базу данных")
  end
end
