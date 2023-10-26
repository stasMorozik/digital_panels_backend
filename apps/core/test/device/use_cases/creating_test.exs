defmodule Device.UseCases.CreatingTest do
  use ExUnit.Case

  alias Core.User.UseCases.Authorization

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.User.Builder, as: UserBuilder

  alias Core.Device.UseCases.Creating

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
      [attributes: [:id, :email, :name, :surname, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :playlists,
      [attributes: [:id, :user_id, :name, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :devices,
      [attributes: [
        :id,
        :user_id,
        :playlist_id,
        :ssh_port,
        :ssh_host,
        :ssh_user,
        :ssh_password,
        :address,
        :longitude,
        :latitude,
        :created,
        :updated
      ]]
    )

    {:atomic, :ok} = :mnesia.add_table_index(:users, :email)
    {:atomic, :ok} = :mnesia.add_table_index(:playlists, :id)

    :ok
  end

  test "Create" do
    {_, user_entity} = UserBuilder.build(%{
      email: "test3@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
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

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.email})

    {result, _} = Creating.create(
      Authorization,
      FakeAdapters.User.Getter,
      FakeAdapters.Playlist.Getter,
      FakeAdapters.Device.Inserting,
      %{
        token: access_token,
        ssh_port: 22,
        ssh_host: "192.168.1.22",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 123",
        longitude: 91.223,
        latitude: -67.99,
        playlist_id: playlist_entity.id
      }
    )
    
    assert result == :ok
  end

  test "Invalid token" do
    {result, _} = Creating.create(
      Authorization,
      FakeAdapters.User.Getter,
      FakeAdapters.Playlist.Getter,
      FakeAdapters.Device.Inserting,
      %{
        token: "invalid token",
        ssh_port: 22,
        ssh_host: "192.168.1.22",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 123",
        longitude: 91.223,
        latitude: -67.99,
        playlist_id: "some id"
      }
    )

    assert result == :error
  end
end
