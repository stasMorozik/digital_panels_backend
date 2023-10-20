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

        with query <- "UPDATE confirmation_codes SET confirmed = true WHERE needle = $1",
             {:ok, q} <- Postgrex.prepare(connection, "", query),
             {:ok, _, _} <- Postgrex.execute(connection, q, [needle]) do
          Success.new(true)
        else
          {:error, _} -> Error.new("Ошибка запроса к базе данных")
        end
        
      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def transform(_) do
    Error.new("Не валидные данные для обновления кода подтверждения в базе данных")
  end
end
