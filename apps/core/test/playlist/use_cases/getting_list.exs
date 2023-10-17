defmodule Playlist.UseCases.CreatingTest do
  use ExUnit.Case

  alias FakeAdapters.Playlist.GettingList, as: GettingListPlaylist
  alias FakeAdapters.User.Getter, as: GetterUser

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


end