defmodule PostgresqlAdapters.ConfirmationCode.Getting do
  alias Core.ConfirmationCode.Ports.Getter
  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  
  alias PostgresqlAdapters.ConfirmationCode.Mapper
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @impl Getter
  def get(needle) when is_binary(needle) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        query = "
          SELECT needle, code, confirmed, created FROM confirmation_codes WHERE needle = $1
        "

        with {:ok, result} <- Executor.execute(query, [needle]),
             true <- result.num_rows > 0,
             [ row ] <- result.rows do
          Mapper.to_entity(row)
        else
          false -> Error.new("Код подтверждения не найден")
          {:exception, message} -> {:exception, message}
        end
      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения кода подтверждения")
  end
end
