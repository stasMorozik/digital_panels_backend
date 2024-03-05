defmodule Content.GettingListTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Content.Inserting
  alias PostgresqlAdapters.Content.GettingList
  alias Core.Content.Builder

  alias Core.Shared.Types.Pagination
  alias Core.Content.Types.Filter
  alias Core.Content.Types.Sort

  doctest PostgresqlAdapters.Content.GettingList

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

  test "Get not empty list" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, file} = Core.File.Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, true} = PostgresqlAdapters.File.Inserting.transform(file, user)

    {:ok, playlist} = Core.Playlist.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Playlist.Inserting.transform(playlist, user)

    {:ok, content} = Builder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file,
      playlist: playlist,
      serial_number: 1
    })

    {:ok, true} = Inserting.transform(content, user)

    {result, list} = GettingList.get(
      %Pagination{
        page: 1,
        limit: 10
      }, 
      %Filter{
        name: "Тест_1234"
      }, 
      %Sort{
        created: "ASC"
      }, 
      user
    )

    leng = length(list)

    assert result == :ok
    assert leng == 1
  end

  test "Get empty list" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")
    
    {result, list} = GettingList.get(
      %Pagination{
        page: 1,
        limit: 10
      }, 
      %Filter{
        name: "Test"
      }, 
      %Sort{
        created: "ASC"
      }, 
      user
    )

    leng = length(list)

    assert result == :ok
    assert leng == 0
  end
end