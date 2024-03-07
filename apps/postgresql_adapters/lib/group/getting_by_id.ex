defmodule PostgresqlAdapters.Group.GettingById do
  alias Core.Group.Ports.Getter
  alias Core.Group.Entity, as: Group
  alias Core.User.Entity, as: User
  
  alias PostgresqlAdapters.Executor

  @behaviour Getter

  @query "
    SELECT 
      groups.id AS gr_id, 
      groups.name AS gr_name, 
      groups.sum AS gr_sum,
      groups.created AS gr_created,
      groups.updated AS gr_updated,
      devices.id AS dev_id,
      devices.ip AS dev_ip,
      devices.latitude AS dev_lat,
      devices.longitude AS dev_long,
      devices.description AS dev_desc,
      devices.created AS dev_created
    FROM 
      relations_user_group 
    JOIN groups ON 
      relations_user_group.group_id = groups.id
    LEFT JOIN devices ON
      devices.group_id = groups.id
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
             fun <- fn ([
                _, _, _, _, _, dev_id, dev_ip, dev_lat, dev_long, dev_desc, dev_created
             ]) -> 
                %Core.Device.Entity{
                  id: UUID.binary_to_string!(dev_id),
                  ip: dev_ip,
                  latitude: Decimal.to_float(dev_lat),
                  longitude: Decimal.to_float(dev_long),
                  desc: dev_desc,
                  created: dev_created,
                }
             end,
             [row | _] <- result.rows,
             [gr_id, gr_name, gr_sum, gr_created, gr_updated, dev_id, _, _, _, _, _] <- row do
          {:ok, %Group{
            id: UUID.binary_to_string!(gr_id),
            name: gr_name,
            sum: gr_sum,
            devices: case dev_id == nil do
              true -> []
              false -> Enum.map(result.rows, fun)
            end,
            created: gr_created,
            updated: gr_updated
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
