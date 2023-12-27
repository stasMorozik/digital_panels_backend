defmodule PostgresqlAdapters.ConfirmationCode.Inserting do
  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Entity

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{} = entity) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        query_1 = "DELETE FROM confirmation_codes WHERE needle = $1"

        query_2 = "
          INSERT INTO confirmation_codes (
            needle, 
            code, 
            confirmed, 
            created
          ) VALUES(
            $1, 
            $2, 
            $3, 
            $4
          )
        "

        with {:ok, query_1} <- Postgrex.prepare(connection, "", query_1),
             {:ok, query_2} <- Postgrex.prepare(connection, "", query_2),
             data <- [entity.needle, entity.code, entity.confirmed, entity.created],
             fun <- fn(conn) ->
                r_0 = Postgrex.execute(conn, q_1, [needle])
                r_1 = Postgrex.execute(conn, q_2, data)

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
          {:error, e} -> Exception.new(e.message)
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def transform(_) do
    {:error, "Не валидные данные для занесения кода подтверждения в базу данных"}
  end
end
