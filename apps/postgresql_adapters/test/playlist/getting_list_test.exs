defmodule Playlist.GettingListTest do
  use ExUnit.Case
  
  alias PostgresqlAdapters.User.Inserting, as: UserInserting
  alias PostgresqlAdapters.Playlist.Inserting, as: PlaylistInserting

  alias Core.User.Builder, as: UserBuilder
  alias Core.Playlist.Builder, as: PlaylistBuilder

  alias PostgresqlAdapters.Playlist.GettingList

  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort
  alias Core.Shared.Types.Pagination

  doctest GettingList

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

    {_, _} = UserInserting.transform(user_entity)

    {_, _} = PlaylistInserting.transform(playlist_entity, user_entity)

    {result, _} = GettingList.get(%Filter{
      user_id: UUID.string_to_binary!(user_entity.id),
      name: nil,
      created_f: nil,
      created_t: nil,
      updated_f: nil,
      updated_t: nil
    }, %Sort{
      name: nil,
      created: nil,
      updated: nil
    }, %Pagination{
      page: 1,
      limit: 10
    })

    assert result == :ok
  end
end