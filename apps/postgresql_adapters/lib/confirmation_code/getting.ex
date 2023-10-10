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

        query = Postgrex.prepare!(
          connection,
          "",
          "SELECT * FROM confirmation_codes WHERE needle = $1"
        )

        case Postgrex.execute(connection, query, [needle]) do
          {:ok, _, result} ->
            with true <- result.num_rows > 0,
                 [ [needle, code, confirmed, created] ] <- result.rows do

              Success.new(%Entity{
                needle: needle,
                created: created,
                code: code,
                confirmed: confirmed
              })

            else
              false -> Error.new("Код подтверждения не найден")
            end
          {:error, _} -> Error.new("Что то пошло не так")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения кода подтверждения")
  end
end
