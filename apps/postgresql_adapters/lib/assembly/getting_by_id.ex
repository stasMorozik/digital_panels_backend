defmodule PostgresqlAdapters.Assembly.GettingById do
  alias Core.Assembly.Ports.Getter
  alias Core.Assembly.Entity, as: Assembly
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @query "
    SELECT 
      assemblies.id AS a_id,
      assemblies.url AS a_url,
      assemblies.type AS a_type,
      assemblies.status AS a_st,
      assemblies.created AS a_created,
      assemblies.updated AS a_updated,
      groups.id AS gr_id, 
      groups.name AS gr_name, 
      groups.sum AS gr_sum,
      groups.created AS gr_created,
      groups.updated AS gr_updated
    FROM 
      relations_user_assembly 
    JOIN assemblies ON 
      relations_user_assembly.assembly_id = assemblies.id
    LEFT JOIN groups ON
      assemblies.group_id = groups.id
    WHERE
      relations_user_assembly.user_id = $1 
    AND
      assemblies.id = $2
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
             [row] <- result.rows,
             [
                a_id, a_url, a_type, a_st, a_created, a_updated,
                gr_id, gr_name, gr_sum, gr_created, gr_updated
             ] <- row do
          {:ok, %Assembly{
            id: UUID.binary_to_string!(a_id),
            group: %Core.Group.Entity{
              id: UUID.binary_to_string!(gr_id), 
              name: gr_name,
              sum: gr_sum,
              created: gr_created, 
              updated: gr_updated
            },
            url: a_url,
            type: a_type,
            status: a_st,
            created: a_created,
            updated: a_updated
          }}
        else
          false -> {:error, "Запись о сборке не найдена в базе данных"}
          {:exception, message} -> {:exception, message}
        end

      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_, _) do
    {:error, "Не валидные данные для получения записи о сборке из базы данных"}
  end
end
