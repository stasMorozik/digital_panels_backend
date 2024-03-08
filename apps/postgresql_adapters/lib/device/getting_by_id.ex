defmodule PostgresqlAdapters.Device.GettingById do
  alias Core.Device.Ports.Getter
  alias Core.Device.Entity, as: Device
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
      devices.is_active AS desc_act,
      devices.created AS dev_created,
      devices.updated AS dev_updated
    FROM 
      relations_user_device 
    JOIN devices ON 
      relations_user_device.device_id = devices.id
    JOIN groups ON
      devices.group_id = groups.id
    WHERE
      relations_user_device.user_id = $1 
    AND
      devices.id = $2
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
                gr_id, 
                gr_name, 
                gr_sum,
                gr_created,
                gr_updated,
                dev_id,
                dev_ip,
                dev_lat,
                dev_long,
                dev_desc,
                desc_act,
                dev_created,
                dev_updated
             ] <- row do
          {:ok, %Device{
            id: UUID.binary_to_string!(dev_id),
            ip: dev_ip, 
            latitude: Decimal.to_float(dev_lat), 
            longitude: Decimal.to_float(dev_long), 
            desc: dev_desc,
            is_active: desc_act,
            group: %Core.Group.Entity{
              id: UUID.binary_to_string!(gr_id), 
              name: gr_name,
              sum: gr_sum,
              created: gr_created, 
              updated: gr_updated
            },
            created: dev_created, 
            updated: dev_updated
          }}
        else
          false -> {:error, "Запись об устройстве не найдена в базе данных"}
          {:exception, message} -> {:exception, message}
        end

      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def get(_, _) do
    {:error, "Не валидные данные для получения записи об устройстве из базы данных"}
  end
end
