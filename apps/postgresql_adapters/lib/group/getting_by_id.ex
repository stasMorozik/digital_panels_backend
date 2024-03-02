defmodule PostgresqlAdapters.Group.GettingById do
  alias Core.Group.Ports.Getter
  alias Core.Group.Entity, as: Group
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @query "
    SELECT 
      groups.id, 
      groups.name, 
      groups.sum,
      groups.created,
      groups.updated
    FROM 
      relations_user_group 
    JOIN groups ON 
      relations_user_group.group_id = groups.id
    WHERE
      relations_user_group.user_id = $1 
    AND
      groups.id = $2
  "

  @impl Getter
  def get(id, %User{} = user) when is_binary(id) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, result} <- Executor.execute(connection, @query, [
                UUID.string_to_binary!(user.id), 
                UUID.string_to_binary!(id)
             ]),
             true <- result.num_rows > 0,
             [ row ] <- result.rows,
             [ id, name, sum, created, updated ] <- row do
          {:ok, %Group{
            id: UUID.binary_to_string!(id),
            name: name,
            sum: sum,
            created: created,
            updated: updated
          }}
        else
          false -> {:error, "Запись о группе не найдена в базе данных"}
          {:exception, message} -> {:exception, message}
        end

      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_, _) do
    {:error, "Не валидные данные для получения записи о группе из базы данных"}
  end
end
