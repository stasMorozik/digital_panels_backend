defmodule Device.InsertingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Device.Inserting, as: DeviceInserting
  alias PostgresqlAdapters.User.Inserting, as: UserInserting
  alias PostgresqlAdapters.Playlist.Inserting, as: PlaylistInserting

  alias Core.Device.Builder, as: DeviceBuilder
  alias Core.User.Builder, as: UserBuilder
  alias Core.Playlist.Builder, as: PlaylistBuilder

  doctest PostgresqlAdapters.Device.Inserting

  setup_all do
    File.touch("/tmp/not_emty.txt", 1544519753)
    
    File.write("/tmp/not_emty.txt", "content")

    :ets.new(:connections, [:set, :public, :named_table])

    {:ok, pid} = Postgrex.start_link(
      hostname: "192.168.0.103",
      username: "db_user",
      password: "12345",
      database: "system_content_manager",
      port: 5437
    )

    :ets.insert(:connections, {"postgresql", "", pid})

    Postgrex.query!(pid, "DELETE FROM relations_user_playlist", [])
    Postgrex.query!(pid, "DELETE FROM relations_user_device", [])
    Postgrex.query!(pid, "DELETE FROM relations_playlist_device", [])

    Postgrex.query!(pid, "DELETE FROM playlists", [])
    Postgrex.query!(pid, "DELETE FROM devices", [])
    Postgrex.query!(pid, "DELETE FROM users WHERE email != 'stasmoriniv@gmail.com'", [])

    :ok
  end

  test "Insert" do
    {:ok, user_entity} = UserBuilder.build(%{
      email: "test@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {:ok, device_entity} = DeviceBuilder.build(%{
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

    {_, _} = UserInserting.transform(user_entity)

    {_, _} = PlaylistInserting.transform(playlist_entity, user_entity)

    {result, _} = DeviceInserting.transform(device_entity, user_entity, playlist_entity)
    
    assert result == :ok
  end

  test "Invalid data" do
    {result, _} = DeviceInserting.transform(nil, nil, nil)

    assert result == :error
  end
end
