defmodule PostgresqlAdapters.Device.Inserting do
  alias Core.Device.Ports.Transformer
  alias Core.Device.Entity, as: DeviceEntity
  alias Core.User.Entity, as: UserEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @behaviour Transformer

  @impl Transformer
  def transform(%DeviceEntity{
    id: id,
    ssh_port: ssh_port,
    ssh_host: ssh_host,
    ssh_user: ssh_user,
    ssh_password: ssh_password,
    address: address,
    longitude: longitude,
    latitude: latitude,
    is_active: is_active,
    created: created,
    updated: updated
  }, %UserEntity{
    id: user_id,
    email: _,
    name: _,
    surname: _,
    created: _,
    updated: _
  }) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        query = Postgrex.prepare!(
          connection,
          "",
          "INSERT INTO devices (
              id,
              user_id,
              ssh_port,
              ssh_host,
              ssh_user,
              ssh_password,
              address,
              longitude,
              latitude,
              is_active,
              created,
              updated
            ) VALUES(
              $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12
            )"
        )

        case Postgrex.execute(connection, query, [
          UUID.string_to_binary!(id),
          UUID.string_to_binary!(user_id),
          ssh_port,
          ssh_host,
          ssh_user,
          ssh_password,
          address,
          longitude,
          latitude,
          is_active,
          created,
          updated
        ]) do
          {:ok, _, _} -> Success.new(true)
          {:error, _} -> Error.new("Устройство уже существует")
        end

      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def transform(_, _) do
    Error.new("Не возможно занести запись в хранилище данных")
  end
end
