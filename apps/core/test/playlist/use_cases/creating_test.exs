defmodule Playlist.UseCases.CreatingTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUserByEmail
  alias User.FakeAdapters.GettingById, as: GettingUserById

  alias Core.User.UseCases.Authentication, as: AuthenticationUseCase

  alias Core.File.Builder, as: FileBuilder
  alias Core.Content.Builder, as: ContentBuilder
  alias File.FakeAdapters.Inserting, as: InsertingFile
  
  alias Content.FakeAdapters.Inserting, as: InsertingContent
  alias Content.FakeAdapters.GettingList, as: GettingListContent

  alias Playlist.FakeAdapters.Inserting, as: InsertingPlaylist

  alias Core.Playlist.UseCases.Creating, as: UseCase

  setup_all do
    File.touch("/tmp/not_emty_png.png", 1544519753)
    File.write("/tmp/not_emty_png.png", "content")

    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)
    :mnesia.delete_table(:users)
    :mnesia.delete_table(:files)
    :mnesia.delete_table(:contents)
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
      :files,
      [attributes: [:id, :path, :url, :extension, :type, :size, :created]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :contents,
      [attributes: [:id, :name, :duration, :file, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :playlists,
      [attributes: [:id, :name, :sum, :contents, :created, :updated]]
    )

    :mnesia.add_table_index(:users, :email)
    :mnesia.add_table_index(:contents, :name)

    :ok
  end

  test "Создание плэйлиста" do
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

    {:ok, file} = FileBuilder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, content} = ContentBuilder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file
    })

    {:ok, true} = InsertingFile.transform(file, user)

    {:ok, true} = InsertingContent.transform(content, user)

    {result, _} = UseCase.create(GettingUserById, GettingListContent, InsertingPlaylist, %{
      pagi: %{
        page: 1,
        limit: 1
      },
      filter: %{
        name: "Тест_1234"
      },
      sort: %{

      },
      name: "Тест_123",
      token: tokens.access_token
    })

    assert result == :ok
  end

  test "Создание плэйлиста - не валидный список контента" do
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

    {:ok, file} = FileBuilder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, content} = ContentBuilder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file
    })

    {:ok, true} = InsertingFile.transform(file, user)

    {:ok, true} = InsertingContent.transform(content, user)

    {result, _} = UseCase.create(GettingUserById, GettingListContent, InsertingPlaylist, %{
      pagi: %{
        page: 1,
        limit: 1
      },
      filter: %{
        name: "Тест_12345"
      },
      sort: %{

      },
      name: "Тест_123",
      token: tokens.access_token
    })

    assert result == :error
  end
end