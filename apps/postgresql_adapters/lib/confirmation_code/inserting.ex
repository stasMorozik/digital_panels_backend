defmodule PostgresqlAdapters.ConfirmationCode.Inserting do
  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Entity

  @pg_secret_key Application.compile_env(:postgresql_adapters, :secret_key)

  @query_0 "DELETE FROM confirmation_codes WHERE pgp_sym_decrypt(needle::bytea, '#{@pg_secret_key}') = $1"

  @query_1 "
    INSERT INTO confirmation_codes (
      needle, 
      code, 
      confirmed, 
      created
    ) VALUES(
      pgp_sym_encrypt($1,'#{@pg_secret_key}'), 
      $2, 
      $3, 
      $4
    )
  "

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{} = entity) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        
        with {:ok, query_1} <- Postgrex.prepare(connection, "", @query_0),
             {:ok, query_2} <- Postgrex.prepare(connection, "", @query_1),
             data <- [entity.needle, entity.code, entity.confirmed, entity.created],
             fun <- fn(conn) ->
                r_0 = Postgrex.execute(conn, query_1, [entity.needle])
                r_1 = Postgrex.execute(conn, query_2, data)

                case {r_0, r_1} do
                  {{:ok, _, _}, {:ok, _, _}} -> {:ok, true}
                  {{:error, e}, {:ok, _, _}} -> DBConnection.rollback(conn, e)
                  {{:ok, _, _}, {:error, e}} -> DBConnection.rollback(conn, e)
                  {{:error, e}, {:error, _}} -> DBConnection.rollback(conn, e)
                end
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          {:ok, true}
        else
          {:error, e} -> {:exception, e.message}
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def transform(_) do
    {:error, "Не валидные данные для занесения кода подтверждения в базу данных"}
  end
end
