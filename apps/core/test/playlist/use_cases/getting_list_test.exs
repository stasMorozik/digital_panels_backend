defmodule Playlist.UseCases.GettingListTest do
  use ExUnit.Case

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.User.Builder, as: UserBuilder

  alias Core.User.UseCases.Authorization

  alias Core.Playlist.UseCases.GettingList

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

    {:atomic, :ok} = :mnesia.add_table_index(:users, :email)
    {:atomic, :ok} = :mnesia.add_table_index(:playlists, :name)

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
            path: "/tmp/not_emty.txt"
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
            path: "/tmp/not_emty.txt"
          },
          display_duration: 15
        }
      ],
      web_dav_url: "http://localhost"
    })

    FakeAdapters.User.Inserting.transform(user_entity)
    FakeAdapters.Playlist.Inserting.transform(playlist_entity_0, user_entity)
    FakeAdapters.Playlist.Inserting.transform(playlist_entity_1, user_entity)

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.email})

    {result, _} = GettingList.get(
      Authorization,
      FakeAdapters.User.Getter,
      FakeAdapters.Playlist.GetterList,
      %{
        token: access_token,
        pagination: %{
          page: 1,
          limit: 10
        },
        filter: %{
          name: "test_0",
          created: "test",
          updated: "test"
        },
        sort: %{
          name: "test",
          created: "test",
          updated: "test"
        }
      }
    )

    assert result == :ok
  end

  test "Invalid token" do
    {result, _} = GettingList.get(
      Authorization,
      FakeAdapters.User.Getter,
      FakeAdapters.Playlist.GetterList,
      %{
        token: "invalid token",
        pagination: %{
          page: 1,
          limit: 10
        },
        filter: %{
          name: "test_0",
          created: "test",
          updated: "test"
        },
        sort: %{
          name: "test",
          created: "test",
          updated: "test"
        }
      }
    )

    assert result == :error
  end
end