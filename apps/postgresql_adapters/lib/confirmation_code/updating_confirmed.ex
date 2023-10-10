defmodule PostgresqlAdapters.ConfirmationCode.UpdatingConfirmed do
  alias Core.ConfirmationCode.Ports.Transformer
  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Transformer

  @impl Transformer
  def transform(%Entity{
    needle: needle,
    created: _,
    code: _,
    confirmed: true
  }) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        query = Postgrex.prepare!(
          connection,
          "",
          "UPDATE confirmation_codes SET confirmed = true WHERE needle = $1"
        )

        case Postgrex.execute(connection, query, [needle]) do
          {:ok, _, _} -> Success.new(true)
          {:error, _} -> Error.new("Не удалоьс обновить код подтверждения")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def transform(_) do
    Error.new("Не валидные данные для обновления кода подтверждения в базе данных")
  end
end
