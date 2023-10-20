defmodule PostgresqlAdapters.ConfirmationCode.Getting do
  alias Core.ConfirmationCode.Ports.Getter
  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Getter

  @impl Getter
  def get(needle) when is_binary(needle) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        with query <- "SELECT * FROM confirmation_codes WHERE needle = $1",
             {:ok, q} <- Postgrex.prepare(connection, "", query),
             {:ok, _, result} <- Postgrex.execute(connection, q, [needle]),
             true <- result.num_rows > 0,
             [ [needle, code, confirmed, created] ] <- result.rows do

          Success.new(%Entity{
            needle: needle,
            created: created,
            code: code,
            confirmed: confirmed
          })
        else
          {:error, _} -> Error.new("Ошибка запроса к базе данных")
          false -> Error.new("Код подтверждения не найден")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения кода подтверждения")
  end
end
