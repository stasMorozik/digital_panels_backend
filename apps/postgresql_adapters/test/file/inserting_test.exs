defmodule File.InsertingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.File.Inserting
  alias Core.File.Builder

  doctest PostgresqlAdapters.File.Inserting

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

  test "Insert" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, file} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {result, _} = Inserting.transform(file, user)

    assert result == :ok
  end

  test "Invalid file" do
    {result, _} = Inserting.transform(%{}, %{})

    assert result == :error
  end

  test "Already exists" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, file} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, true} = Inserting.transform(file, user)

    {result, _} = Inserting.transform(file, user)

    assert result == :error
  end

  # test "Exception: " do
  #   user_entity = %Entity{
  #     id: "cef89cb9-3d5a-4f2c-97b9-d047347f2e53",
  #     email: "some_long_email@gmail.com",
  #     name: "name",
  #     surname: "surname",
  #     created: ~D[2024-01-01],
  #     updated: ~D[2024-01-01]
  #   }

  #   {result, _} = Inserting.transform(user_entity)

  #   assert result == :exception
  # end
end
