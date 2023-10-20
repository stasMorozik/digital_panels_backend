defmodule PostgresqlAdapters.Device.Inserting do
  alias Core.Device.Ports.Transformer
  alias Core.Device.Entity, as: DeviceEntity
  alias Core.User.Entity, as: UserEntity
  alias Core.Playlist.Entity, as: PlaylistEntity

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
  }, %PlaylistEntity{
    id: playlist_id,
    name: _,
    contents: _,
    created: _,
    updated: _
  }) do
    case :ets.lookup(:connections, "postgresql") do
      [{"postgresql", "", connection}] ->

        query_0 = "
          INSERT INTO devices (
            id,
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
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11
          )
        "

        query_1 = "
          INSERT INTO relations_user_device (
            user_id,
            device_id
          ) VALUES(
            $1, $2
          )
        "

        query_2 = "
          INSERT INTO relations_playlist_device (
            playlist_id,
            device_id
          ) VALUES(
            $1, $2
          )
        "

        with {:ok, q_0} <- Postgrex.prepare(connection, "", query_0),
             {:ok, q_1} <- Postgrex.prepare(connection, "", query_1),
             {:ok, q_2} <- Postgrex.prepare(connection, "", query_2),
             d_0 <- [
                UUID.string_to_binary!(id),
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
             ],
             d_1 <- [
                UUID.string_to_binary!(user_id),
                UUID.string_to_binary!(id),
             ],
             d_2 <- [
                UUID.string_to_binary!(playlist_id),
                UUID.string_to_binary!(id),
             ],
             fun <- fn(conn) ->
                Postgrex.execute(conn, q_0, d_0)
                Postgrex.execute(conn, q_1, d_1)
                Postgrex.execute(conn, q_2, d_2)
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          Success.new(true)
        else 
          {:error, _} -> Error.new("Ошибка запроса к базе данных")
        end
      [] -> Error.new("Database connection error")
      _ -> Error.new("Database connection error")
    end
  end

  def transform(_, _, _) do
    Error.new("Не возможно занести запись в хранилище данных")
  end
end
