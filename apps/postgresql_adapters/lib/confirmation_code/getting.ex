defmodule PostgresqlAdapters.ConfirmationCode.Getting do
  alias Core.ConfirmationCode.Ports.Getter
  alias Core.ConfirmationCode.Entity

  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @pg_secret_key Application.compile_env(:postgresql_adapters, :secret_key)

  @query "
    SELECT 
      pgp_sym_decrypt(needle::bytea, '#{@pg_secret_key}'), 
      code, 
      confirmed, 
      created 
    FROM 
      confirmation_codes 
    WHERE 
      pgp_sym_decrypt(needle::bytea, '#{@pg_secret_key}') = $1
  "

  @impl Getter
  def get(needle) when is_binary(needle) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        query = @query

        with {:ok, result} <- Executor.execute(connection, query, [needle]),
             true <- result.num_rows > 0,
             [ row ] <- result.rows,
             [needle, code, confirmed, created] <- row do
          {:ok, %Entity{
            needle: needle,
            created: created,
            code: code,
            confirmed: confirmed
          }}
        else
          false -> {:error, "Запись о коде подтверждения не найдена в базе данных"}
          {:exception, message} -> {:exception, message}
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_) do
    {:error, "Не валидные данные для получения записи о коде подтверждении из базы данных"}
  end
end
