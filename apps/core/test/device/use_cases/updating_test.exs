defmodule Device.UseCases.UpdatingTest do
  use ExUnit.Case

  alias Core.User.UseCases.Authorization

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.Device.Builder, as: DeviceBuilder
  alias Core.User.Builder, as: UserBuilder

  alias Core.Device.UseCases.Updating

  setup_all do
    File.touch("/tmp/not_emty.txt", 1544519753)
    
    File.write("/tmp/not_emty.txt", "content")

    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:devices)

    :mnesia.delete_table(:users)

    :mnesia.delete_table(:playlists)

    {:atomic, :ok} = :mnesia.create_table(
      :users,
      [attributes: [:name, :id, :email, :surname, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :playlists,
      [attributes: [:created, :user_id, :name, :id, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :devices,
      [attributes: [
        :ssh_port,
        :id,
        :ssh_host,
        :ssh_user,
        :ssh_password,
        :address,
        :longitude,
        :latitude,
        :is_active,
        :created,
        :updated
      ]]
    )

    {:atomic, :ok} = :mnesia.add_table_index(:users, :id)
    {:atomic, :ok} = :mnesia.add_table_index(:playlists, :id)
    {:atomic, :ok} = :mnesia.add_table_index(:devices, :id)

    :ok
  end

  test "Update" do
    {_, user_entity} = UserBuilder.build(%{
      email: "test3@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {_, device_entity_0} = DeviceBuilder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "NY Long street 1234",
      longitude: 91.223,
      latitude: -67.99
    })

    {_, playlist_entity} = PlaylistBuilder.build(%{
      name: "test",
      contents: [
        %{
          file: %{
            path: "/tmp/not_emty.txt"
          },
          display_duration: 15
        }
      ],
      web_dav_url: "http://localhost"
    })

    FakeAdapters.User.Inserting.transform(user_entity)
    FakeAdapters.Playlist.Inserting.transform(playlist_entity, user_entity)
    FakeAdapters.Device.Inserting.transform(device_entity_0, user_entity, playlist_entity)
    
    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.id})

    {result, _} = Updating.update(
      Authorization,
      FakeAdapters.User.GetterById,
      FakeAdapters.Device.Getter,
      FakeAdapters.Playlist.Getter,
      FakeAdapters.Device.Updating,
      %{
        id: device_entity_0.id,
        token: access_token,
        ssh_port: nil,
        ssh_host: "192.168.1.23",
        ssh_user: nil,
        ssh_password: nil,
        address: nil,
        longitude: nil,
        latitude: nil,
        playlist_id: playlist_entity.id,
        is_active: nil
      }
    )
    
    assert result == :ok
  end
end