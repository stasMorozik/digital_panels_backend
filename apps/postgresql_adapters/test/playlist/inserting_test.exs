defmodule Playlist.InsertingTest do
  use ExUnit.Case
  
  alias PostgresqlAdapters.User.Inserting, as: UserInserting
  alias PostgresqlAdapters.Playlist.Inserting, as: PlaylistInserting

  alias Core.User.Builder, as: UserBuilder
  alias Core.Playlist.Builder, as: PlaylistBuilder

  doctest PostgresqlAdapters.Device.Inserting

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

  test "Insert" do
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

    {_, _} = UserInserting.transform(user_entity)

    {result, _} = PlaylistInserting.transform(playlist_entity, user_entity)
    
    assert result == :ok
  end

  test "Invalid data" do
    {result, _} = PlaylistInserting.transform(nil, nil)

    assert result == :error
  end

  test "Already exists" do
    {:ok, user_entity} = UserBuilder.build(%{
      email: "test34@gmail.com", 
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

    {_, _} = UserInserting.transform(user_entity)

    {_, _} = PlaylistInserting.transform(playlist_entity, user_entity)

    {result, _} = PlaylistInserting.transform(playlist_entity, user_entity)
    
    assert result == :error
  end

  test "Exception" do
    {:ok, user_entity} = UserBuilder.build(%{
      email: "test345@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    name_0 = "some_test_some_test_some_test_some_test_some_test_some_test_some_test_some_test_some_test_some_test_some_test_"
    name_1 = "some_test_some_test_some_test_some_test_some_test_some_test_some_test_some_test_some_test_some_test_some_test_"

    {_, playlist_entity} = PlaylistBuilder.build(%{
      name: name_0 <> name_1,
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

    {result, _} = PlaylistInserting.transform(playlist_entity, user_entity)
    
    assert result == :exception
  end
end
