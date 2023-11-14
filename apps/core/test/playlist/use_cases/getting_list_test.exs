defmodule Playlist.UseCases.GettingListTest do
  use ExUnit.Case

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.User.Builder, as: UserBuilder

  alias Core.User.UseCases.Authorization

  alias Core.Playlist.UseCases.GettingList

  setup_all do
    File.touch("/tmp/not_emty.png", 1544519753)
    
    File.write("/tmp/not_emty.png", "content")

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

    {:atomic, :ok} = :mnesia.add_table_index(:playlists, :name)
    {:atomic, :ok} = :mnesia.add_table_index(:users, :id)

    :ok
  end

  test "Get list" do
    {_, user_entity} = UserBuilder.build(%{
      email: "test3@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {_, playlist_entity_0} = PlaylistBuilder.build(%{
      name: "test_0",
      contents: [
        %{
          file: %{
            path: "/tmp/not_emty.png"
          },
          display_duration: 15
        }
      ],
      web_dav_url: "http://localhost"
    })

    {_, playlist_entity_1} = PlaylistBuilder.build(%{
      name: "test_1",
      contents: [
        %{
          file: %{
            path: "/tmp/not_emty.png"
          },
          display_duration: 15
        }
      ],
      web_dav_url: "http://localhost"
    })

    FakeAdapters.User.Inserting.transform(user_entity)
    FakeAdapters.Playlist.Inserting.transform(playlist_entity_0, user_entity)
    FakeAdapters.Playlist.Inserting.transform(playlist_entity_1, user_entity)

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.id})

    {result, _} = GettingList.get(
      Authorization,
      FakeAdapters.User.GetterById,
      FakeAdapters.Playlist.GetterList,
      %{
        token: access_token,
        pagi: %{
          page: 1,
          limit: 10
        },
        filter: %{
          created_f: nil,
          created_t: nil,
          name: "test_0"
        },
        sort: %{
          name: "asc",
          created: nil
        }
      }
    )

    assert result == :ok
  end

  test "Invalid token" do
    {result, _} = GettingList.get(
      Authorization,
      FakeAdapters.User.GetterById,
      FakeAdapters.Playlist.GetterList,
      %{
        token: "invalid token",
        pagi: %{
          page: 1,
          limit: 10
        },
        filter: %{
          created_f: nil,
          created_t: nil,
          name: "test_0"
        },
        sort: %{
          name: "asc",
          created: nil
        }
      }
    )

    assert result == :error
  end
end