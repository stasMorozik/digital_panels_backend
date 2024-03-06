defmodule Task.GettingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Task.Inserting
  alias PostgresqlAdapters.Task.GettingById
  alias Core.Task.Builder

  doctest PostgresqlAdapters.Task.GettingById

  setup_all do
    :ets.new(:connections, [:set, :public, :named_table])

    {:ok, pid} = Postgrex.start_link(
      hostname: Application.fetch_env!(:postgresql_adapters, :hostname),
      username: Application.fetch_env!(:postgresql_adapters, :username),
      password: Application.fetch_env!(:postgresql_adapters, :password),
      database: Application.fetch_env!(:postgresql_adapters, :database),
      port: Application.fetch_env!(:postgresql_adapters, :port)
    )

    :ets.insert(:connections, {"postgresql", "", pid})

    File.touch("/tmp/not_emty_png.png", 1544519753)
    File.write("/tmp/not_emty_png.png", "content")

    Postgrex.query!(pid, "DELETE FROM relations_user_assembly", [])
    Postgrex.query!(pid, "DELETE FROM assemblies", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_task", [])
    Postgrex.query!(pid, "DELETE FROM tasks", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_content", [])
    Postgrex.query!(pid, "DELETE FROM contents", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_file", [])
    Postgrex.query!(pid, "DELETE FROM files", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_playlist", [])
    Postgrex.query!(pid, "DELETE FROM playlists", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_device", [])
    Postgrex.query!(pid, "DELETE FROM devices", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_group", [])
    Postgrex.query!(pid, "DELETE FROM groups", [])

    :ok
  end

  test "Get by id" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Group.Inserting.transform(group, user)

    {:ok, playlist} = Core.Playlist.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Playlist.Inserting.transform(playlist, user)

    {:ok, file} = Core.File.Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, true} = PostgresqlAdapters.File.Inserting.transform(file, user)

    {:ok, content} = Core.Content.Builder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file,
      playlist: playlist,
      serial_number: 1
    })

    {:ok, true} = PostgresqlAdapters.Content.Inserting.transform(content, user)

    {:ok, content} = Core.Content.Builder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file,
      playlist: playlist,
      serial_number: 2
    })

    {:ok, true} = PostgresqlAdapters.Content.Inserting.transform(content, user)

    {:ok, task} = Builder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 1,
      end_hour: 5,
      start_minute: 0,
      end_minute: 30
    })

    {:ok, true} = Inserting.transform(task, user)

    {result, _} = GettingById.get(task.id, user)
    
    assert result == :ok
  end

  test "Task not found with id" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {result, _} = GettingById.get(UUID.uuid4(), user)

    assert result == :error
  end

  test "Task not found with id of user" do
    {:ok, user_0} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, user_1} = Core.User.Builder.build(%{
      email: "test@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Group.Inserting.transform(group, user_0)

    {:ok, playlist} = Core.Playlist.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Playlist.Inserting.transform(playlist, user_0)

    {:ok, file} = Core.File.Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, true} = PostgresqlAdapters.File.Inserting.transform(file, user_0)

    {:ok, content} = Core.Content.Builder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file,
      playlist: playlist,
      serial_number: 1
    })

    {:ok, true} = PostgresqlAdapters.Content.Inserting.transform(content, user_0)

    {:ok, content} = Core.Content.Builder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file,
      playlist: playlist,
      serial_number: 2
    })

    {:ok, true} = PostgresqlAdapters.Content.Inserting.transform(content, user_0)

    {:ok, task} = Builder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 1,
      end_hour: 5,
      start_minute: 0,
      end_minute: 30
    })

    {:ok, true} = Inserting.transform(task, user_0)

    {result, _} = GettingById.get(task.id, user_1)

    assert result == :error
  end

  # test "Exception" do
  #   {:ok, user_entity} = Builder.build(%{email: "test123@gmail.com", name: "Пётр", surname: "Павел"})

  #   Inserting.transform(user_entity)

  #   {result, _} = GettingById.get(<<104, 101, 197, 130, 197, 130, 60, 158, 104, 101, 197, 130, 197, 130, 46, 90>>)

  #   assert result == :error
  # end
end
