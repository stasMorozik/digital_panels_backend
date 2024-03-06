defmodule Task.UseCases.CreatingTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUserByEmail
  alias User.FakeAdapters.GettingById, as: GettingUserById

  alias Core.User.UseCases.Authentication, as: AuthenticationUseCase

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Playlist.FakeAdapters.Inserting, as: InsertingPlaylist
  alias Playlist.FakeAdapters.Getting, as: GettingPlaylist

  alias Core.Group.Builder, as: GroupBuilder
  alias Group.FakeAdapters.Inserting, as: InsertingGroup
  alias Group.FakeAdapters.Getting, as: GettingGroup

  alias Core.Task.Builder, as: TaskBuilder
  alias Task.FakeAdapters.GettingList, as: GettingListTask
  alias Task.FakeAdapters.Inserting, as: InsertingTask

  alias Core.Task.UseCases.Creating, as: UseCase

  setup_all do

    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)
    :mnesia.delete_table(:users)
    :mnesia.delete_table(:playlists)
    :mnesia.delete_table(:groups)
    :mnesia.delete_table(:tasks)

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

    {:atomic, :ok} = :mnesia.create_table(
      :groups,
      [attributes: [:id, :name, :sum, :devices, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :tasks,
      [attributes: [
        :id, 
        :name,
        :playlist,
        :group,
        :type,
        :day,
        :start_hour,
        :end_hour,
        :start_minute,
        :end_minute,
        :start_a,
        :end_a,
        :sum,
        :created, 
        :updated
      ]]
    )

    :mnesia.add_table_index(:users, :email)

    :mnesia.add_table_index(:tasks, :start_a)

    :ok
  end

  test "Создание задания" do
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

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, true} = InsertingGroup.transform(group, user)

    {result, _} = UseCase.create(
      GettingUserById,
      GettingPlaylist,
      GettingGroup,
      GettingListTask,
      InsertingTask,
      %{
        playlist_id: playlist.id,
        group_id: group.id,
        token: tokens.access_token,
        name: "Тест_1234",
        type: "Каждый день",
        day: nil, 
        start_hour: 1,
        end_hour: 2,
        start_minute: 0,
        end_minute: 30
      }
    )

    assert result == :ok
  end

  test "Создание задания - задание с таким типом и временным интервалом уже существует" do
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

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, true} = InsertingGroup.transform(group, user)

    {:ok, task} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 4,
      end_hour: 5,
      start_minute: 0,
      end_minute: 30
    })

    {:ok, true} = InsertingTask.transform(task, user)

    {result, _} = UseCase.create(
      GettingUserById,
      GettingPlaylist,
      GettingGroup,
      GettingListTask,
      InsertingTask,
      %{
        playlist_id: playlist.id,
        group_id: group.id,
        token: tokens.access_token,
        name: "Тест_1234",
        type: "Каждый день",
        day: nil, 
        start_hour: 4,
        end_hour: 5,
        start_minute: 0,
        end_minute: 30
      }
    )

    assert result == :error
  end
end