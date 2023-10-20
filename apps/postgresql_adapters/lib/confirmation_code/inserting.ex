defmodule PostgresqlAdapters.ConfirmationCode.Inserting do
  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

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

        with query_1 = "DELETE FROM confirmation_codes",
             query_2 = "INSERT INTO confirmation_codes (needle, code, confirmed, created) VALUES($1, $2, $3, $4)",
             {:ok, q_1} <- Postgrex.prepare(connection, "", query_1),
             {:ok, q_2} <- Postgrex.prepare(connection, "", query_2),
             data <- [needle, code, confirmed, created],
             fun <- fn(conn) ->
                Postgrex.execute(conn, q_1, [])
                Postgrex.execute(conn, q_2, data)
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          Success.new(true)
        else
          {:error, _} -> Error.new("Ошибка запроса к базе данных")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def transform(_) do
    Error.new("Не валидные данные для занесения кода подтверждения в базу данных")
  end
end
