defmodule FakeAdapters.Device.Updating do
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
    case :mnesia.transaction(
      fn -> :mnesia.write({
        :devices,
          ssh_port,
          id,
          ssh_host,
          ssh_user,
          ssh_password,
          address,
          longitude,
          latitude,
          is_active,
          created,
          updated
      }) end
    ) do
      {:atomic, :ok} -> Success.new(true)
      {:aborted, _} -> Error.new("Устройство уже существует")
    end
  end

  def transform(_, _) do
    Error.new("Не возможно занести запись в хранилище данных")
  end
end