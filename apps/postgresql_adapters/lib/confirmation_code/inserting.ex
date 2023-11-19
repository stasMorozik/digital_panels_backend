defmodule PostgresqlAdapters.ConfirmationCode.Inserting do
  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{
    needle: needle,
    created: created,
    code: code,
    confirmed: confirmed
  }) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        with query_1 = "DELETE FROM confirmation_codes WHERE needle = $1",
             query_2 = "INSERT INTO confirmation_codes (needle, code, confirmed, created) VALUES($1, $2, $3, $4)",
             {:ok, q_1} <- Postgrex.prepare(connection, "", query_1),
             {:ok, q_2} <- Postgrex.prepare(connection, "", query_2),
             data <- [needle, code, confirmed, created],
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
          Success.new(true)
        else
          {:error, e} -> Exception.new(e.message)
        end

      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def transform(_) do
    Error.new("Не валидные данные для занесения кода подтверждения в базу данных")
  end
end
