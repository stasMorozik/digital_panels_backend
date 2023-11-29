defmodule PostgresqlAdapters.Device.Inserting do
  alias Core.Device.Ports.Transformer
  alias Core.Device.Entity, as: DeviceEntity
  alias Core.User.Entity, as: UserEntity
  alias Core.Playlist.Entity, as: PlaylistEntity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Shared.Types.Exception

  @behaviour Transformer

  @impl Transformer
  def transform(%DeviceEntity{} = device, %UserEntity{} = user, %PlaylistEntity{} = playlist) do
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
                UUID.string_to_binary!(device.id),
                device.ssh_port,
                device.ssh_host,
                device.ssh_user,
                device.ssh_password,
                device.address,
                device.longitude,
                device.latitude,
                device.is_active,
                device.created,
                device.updated
             ],
             d_1 <- [
                UUID.string_to_binary!(user.user_id),
                UUID.string_to_binary!(device.id),
             ],
             d_2 <- [
                UUID.string_to_binary!(playlist.playlist_id),
                UUID.string_to_binary!(device.id),
             ],
             fun <- fn(conn) ->
                r_0 = Postgrex.execute(conn, q_0, d_0)
                r_1 = Postgrex.execute(conn, q_1, d_1)
                r_2 = Postgrex.execute(conn, q_2, d_2)

                case {r_0, r_1, r_2} do
                  {{:ok, _, _}, {:ok, _, _}, {:ok, _, _}} -> {:ok, true}
                  {{:error, e}, {:ok, _, _}, {:ok, _, _}} -> DBConnection.rollback(conn, e)
                  {{:ok, _, _}, {:error, e}, {:ok, _, _}} -> DBConnection.rollback(conn, e)
                  {{:ok, _, _}, {:ok, _, _}, {:error, e}} -> DBConnection.rollback(conn, e)
                  {{:ok, _, _}, {:error, e}, {:error, _}} -> DBConnection.rollback(conn, e)
                  {{:error, e}, _, _} -> DBConnection.rollback(conn, e)
                end
             end,
             {:ok, _} <- Postgrex.transaction(connection, fun) do
          Success.new(true)
        else
          {:error, %Postgrex.Error{postgres: %{pg_code: "23505"}}} -> Error.new("Устройство уже существует")
          {:error, e} -> Exception.new(e.message)
        end
      [] -> Exception.new("Database connection error")
      _ -> Exception.new("Database connection error")
    end
  end

  def transform(_, _, _) do
    Error.new("Не возможно занести запись в хранилище данных")
  end
end
