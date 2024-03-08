defmodule PostgresqlAdapters.Device.Updating do
  
  alias Core.Device.Ports.Transformer
  alias Core.Device.Entity, as: Device
  alias Core.User.Entity, as: User

  @behaviour Transformer
  
  @query_0 "
    UPDATE 
      devices AS d 
    SET
      ip = $3,
      latitude = $4,
      longitude = $5,
      description = $6,
      is_active = $7,
      group_id = $8,
      updated = $9
    FROM 
      relations_user_device AS r
    WHERE 
      r.user_id = $1
    AND
      d.id = $2
  "

  @impl Transformer
  def transform(%Device{} = device, %User{} = user) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->
        with {:ok, query_0} <- Postgrex.prepare(connection, "", @query_0),
             data_0 <- [
                UUID.string_to_binary!(user.id),
                UUID.string_to_binary!(device.id),
                device.ip,
                device.latitude,
                device.longitude,
                device.desc,
                device.is_active,
                UUID.string_to_binary!(device.group.id),
                device.updated
             ],
             fun <- fn(conn) ->
                r_0 = Postgrex.execute(conn, query_0, data_0)

                case r_0 do
                  {:ok, _, _} -> {:ok, true}
                  {:error, e} -> DBConnection.rollback(conn, e)
                end
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          {:ok, true}
        else
          {:error, e} -> {:exception, e}
        end
      [] -> {:exception, "Database connection error"}
      _ -> {:exception, "Database connection error"}
    end
  end

  def transform(_, _) do
    {:error, "Не валидные данные для занесения записи об устройстве в базу данных"}
  end
end