defmodule PostgresqlAdapters.Device.Getting do
  alias Core.Device.Ports.Getter
  alias Core.Device.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  alias PostgresqlAdapters.Executor
  alias PostgresqlAdapters.Device.Mapper

  @behaviour Getter

  @impl Getter
  def get(id) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        query = "
          SELECT 
            id, 
            address, 
            ssh_host, 
            ssh_port, 
            ssh_user, 
            ssh_password,
            is_active, 
            longitude, 
            latitude, 
            created, 
            updated
          FROM devices WHERE id = $1
        "

        with {:ok, result} <- Executor.execute(query, [id]),
             true <- result.num_rows > 0,
             [row] <- result.rows do
          Mapper.to_entity(row)
        else
          false -> Error.new("Плэйлист не найден")
          {:exception, message} -> {:exception, message}
        end
      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def get(_) do
    Error.new("Не валидные данные для получения пользователя")
  end
end
