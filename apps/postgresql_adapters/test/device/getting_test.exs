defmodule Device.GettingTest do
  use ExUnit.Case
  
  alias PostgresqlAdapters.User.Inserting, as: UserInserting
  alias PostgresqlAdapters.Playlist.Inserting, as: PlaylistInserting
  alias PostgresqlAdapters.Device.Inserting, as: DeviceInserting

  alias Core.User.Builder, as: UserBuilder
  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.Device.Builder, as: DeviceBuilder

  alias PostgresqlAdapters.Device.Getting

  alias Core.Device.Types.Filter
  alias Core.Device.Types.Sort
  alias Core.Shared.Types.Pagination

  doctest Getting

  setup_all do
    File.touch("/tmp/not_emty.txt", 1544519753)
    
    File.write("/tmp/not_emty.txt", "content")

    :ets.new(:connections, [:set, :public, :named_table])

    {:ok, pid} = Postgrex.start_link(
      hostname: Application.fetch_env!(:postgresql_adapters, :hostname),
      username: Application.fetch_env!(:postgresql_adapters, :username),
      password: Application.fetch_env!(:postgresql_adapters, :password),
      database: Application.fetch_env!(:postgresql_adapters, :database),
      port: Application.fetch_env!(:postgresql_adapters, :port)
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

  test "Get" do
    {:ok, user_entity} = UserBuilder.build(%{
      email: "test@gmail.com", 
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

    {_, device_entity} = DeviceBuilder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "NY Long street 1234",
      longitude: 91.223,
      latitude: -67.99
    })

    {_, _} = UserInserting.transform(user_entity)

    {_, _} = PlaylistInserting.transform(playlist_entity, user_entity)

    {_, _} = DeviceInserting.transform(device_entity, user_entity, playlist_entity)

    {result, _} = Getting.get(UUID.string_to_binary!(device_entity.id))
    
    assert result == :ok
  end

  test "Not found" do
    {_, device_entity} = DeviceBuilder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "NY Long street 1234",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Getting.get(UUID.string_to_binary!(device_entity.id))
    
    assert result == :error
  end
end