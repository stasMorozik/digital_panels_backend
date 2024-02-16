defmodule PostgresqlAdapters.User.Inserting do
  alias Core.User.Ports.Transformer
  alias Core.User.Entity

  @behaviour Transformer

  @pg_secret_key Application.compile_env(:postgresql_adapters, :secret_key, "!qazSymKeyXsw2")

  @query "
    INSERT INTO users (
      id, email, name, surname, created, updated
    ) VALUES(
      $1,
      pgp_sym_encrypt($2,'#{@pg_secret_key}'), 
      pgp_sym_encrypt($3,'#{@pg_secret_key}'), 
      pgp_sym_encrypt($4,'#{@pg_secret_key}'),
      $5, 
      $6
    )
  "

  @impl Transformer
  def transform(%Entity{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        query = @query

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
          {:error, e} -> {:exception, e}
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def transform(_) do
    {:error, "Не валидные данные для занесения пользователя в базу данных"}
  end
end
