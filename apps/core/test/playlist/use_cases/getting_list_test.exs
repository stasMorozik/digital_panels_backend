defmodule Playlist.UseCases.GettingListTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUserByEmail
  alias User.FakeAdapters.GettingById, as: GettingUserById

  alias Core.User.UseCases.Authentication, as: AuthenticationUseCase

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Playlist.FakeAdapters.Inserting, as: InsertingPlaylist
  alias Playlist.FakeAdapters.GettingList, as: GettingListPlaylist

  alias Core.Playlist.UseCases.GettingList, as: UseCase

  setup_all do
    File.touch("/tmp/not_emty_png.png", 1544519753)
    File.write("/tmp/not_emty_png.png", "content")

    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)
    :mnesia.delete_table(:users)
    :mnesia.delete_table(:playlists)

    {:atomic, :ok} = :mnesia.create_table(
      :codes,
      [attributes: [:needle, :created, :code, :confirmed]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :users,
      [attributes: [:id, :email, :name, :surname, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :playlists,
      [attributes: [:id, :name, :sum, :contents, :created, :updated]]
    )

    :mnesia.add_table_index(:users, :email)
    :mnesia.add_table_index(:playlists, :name)

    :ok
  end

  test "Получение списка плэйлистов" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    
    {:ok, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test@gmail.com",
      code: code.code
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {:ok, true} = InsertingPlaylist.transform(playlist, user)

    {result, _} = UseCase.get(
      GettingUserById, 
      GettingListPlaylist,
      %{
        pagi: %{
          page: 1,
          limit: 1
        },
        filter: %{
          name: "Тест_1234"
        },
        sort: %{
        },
        token: tokens.access_token,
      }
    )

    assert result == :ok
  end

  test "Получение списка плэйлистов - не валидный токен" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {:ok, true} = InsertingPlaylist.transform(playlist, user)

    {result, _} = UseCase.get(
      GettingUserById, 
      GettingListPlaylist,
      %{
        pagi: %{
          page: 1,
          limit: 1
        },
        filter: %{
          name: "Тест_1234"
        },
        sort: %{
        },
        token: "Invalid_token",
      }
    )

    assert result == :error
  end
end