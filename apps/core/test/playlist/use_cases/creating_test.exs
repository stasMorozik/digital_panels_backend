defmodule Playlist.UseCases.CreatingTest do
  use ExUnit.Case

  alias Core.User.UseCases.Authorization

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.User.Builder, as: UserBuilder

  alias Core.Playlist.UseCases.Creating

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

    {:atomic, :ok} = :mnesia.add_table_index(:users, :id)

    :ok
  end

  test "Create" do
    {_, user_entity} = UserBuilder.build(%{
      email: "test3@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    FakeAdapters.User.Inserting.transform(user_entity)

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.id})

    {result, _} = Creating.create(
      Authorization,
      FakeAdapters.User.GetterById,
      FakeAdapters.File.Inserting,
      FakeAdapters.Playlist.Inserting,
      %{
        token: access_token,
        web_dav_url: "http://localhost",
        name: "test_2",
        contents: [
          %{
            file: %{
              path: "/tmp/not_emty.png"
            },
            display_duration: 15
          }
        ]
      }
    )

    assert result == :ok
  end

  test "Invalid token" do
    {result, _} = Creating.create(
      Authorization,
      FakeAdapters.User.GetterById,
      FakeAdapters.File.Inserting,
      FakeAdapters.Playlist.Inserting,
      %{
        token: "invalid token",
        web_dav_url: "http://localhost",
        name: "test_2",
        contents: [
          %{
            file: %{
              path: "/tmp/not_emty.png"
            },
            display_duration: 15
          }
        ]
      }
    )

    assert result == :error
  end
end
