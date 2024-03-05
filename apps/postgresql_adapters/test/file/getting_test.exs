defmodule File.GettingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.File.Inserting
  alias PostgresqlAdapters.File.GettingById
  alias Core.File.Builder

  doctest PostgresqlAdapters.File.GettingById

  setup_all do
    :ets.new(:connections, [:set, :public, :named_table])

    File.touch("/tmp/not_emty_png.png", 1544519753)
    File.write("/tmp/not_emty_png.png", "content")

    {:ok, pid} = Postgrex.start_link(
      hostname: Application.fetch_env!(:postgresql_adapters, :hostname),
      username: Application.fetch_env!(:postgresql_adapters, :username),
      password: Application.fetch_env!(:postgresql_adapters, :password),
      database: Application.fetch_env!(:postgresql_adapters, :database),
      port: Application.fetch_env!(:postgresql_adapters, :port)
    )

    :ets.insert(:connections, {"postgresql", "", pid})

    Postgrex.query!(pid, "DELETE FROM relations_user_task", [])
    Postgrex.query!(pid, "DELETE FROM tasks", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_content", [])
    Postgrex.query!(pid, "DELETE FROM contents", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_file", [])
    Postgrex.query!(pid, "DELETE FROM files", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_playlist", [])
    Postgrex.query!(pid, "DELETE FROM playlists", [])

    :ok
  end

  test "Get by id" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, file} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, true} = Inserting.transform(file, user)

    {result, _} = GettingById.get(file.id, user)

    assert result == :ok
  end

  test "File not found with id" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, file} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {result, _} = GettingById.get(file.id, user)

    assert result == :error
  end

  test "File not found with id of user" do
    {:ok, user_0} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, user_1} = Core.User.Builder.build(%{
      email: "test@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {:ok, file} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, true} = Inserting.transform(file, user_0)

    {result, _} = GettingById.get(file.id, user_1)

    assert result == :error
  end

  # test "Exception" do
  #   {:ok, user_entity} = Builder.build(%{email: "test123@gmail.com", name: "Пётр", surname: "Павел"})

  #   Inserting.transform(user_entity)

  #   {result, _} = GettingById.get(<<104, 101, 197, 130, 197, 130, 60, 158, 104, 101, 197, 130, 197, 130, 46, 90>>)

  #   assert result == :error
  # end
end
