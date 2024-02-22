defmodule PostgresqlAdapters.User.Getting do
  alias Core.User.Ports.Getter
  alias Core.User.Entity

  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @pg_secret_key Application.compile_env(:postgresql_adapters, :secret_key)

  @query "SELECT id, pgp_sym_decrypt(email::bytea, '#{@pg_secret_key}'), pgp_sym_decrypt(name::bytea, '#{@pg_secret_key}'), pgp_sym_decrypt(surname::bytea, '#{@pg_secret_key}'), created, updated FROM users WHERE pgp_sym_decrypt(email::bytea, '#{@pg_secret_key}') = $1"

  @impl Getter
  def get(email) when is_binary(email) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, result} <- Executor.execute(connection, @query, [email]),
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
