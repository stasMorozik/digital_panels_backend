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

        query = Postgrex.prepare!(
          connection,
          "",
          "INSERT INTO confirmation_codes (needle, code, confirmed, created) VALUES($1, $2, $3, $4)"
        )

        {result, _} = Postgrex.transaction(connection, fn(conn) ->
          Postgrex.query!(conn, "DELETE FROM confirmation_codes", [])
          Postgrex.execute(conn, query, [needle, code, confirmed, created])
        end)

        case result do
          :ok -> Success.new(true)
          :error -> Error.new("Код подтверждения уже существует")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def transform(_) do
    Error.new("Не валидные данные для занесения кода подтверждения в базу данных")
  end
end
