defmodule File.GettingListTest do
  use ExUnit.Case

  alias PostgresqlAdapters.File.Inserting
  alias PostgresqlAdapters.File.GettingList
  alias Core.File.Builder

  alias Core.Shared.Types.Pagination
  alias Core.File.Types.Filter
  alias Core.File.Types.Sort

  doctest PostgresqlAdapters.File.GettingList

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

    Postgrex.query!(pid, "DELETE FROM relations_user_file", [])
    Postgrex.query!(pid, "DELETE FROM files", [])

    :ok
  end

  test "Get not empty list" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, file} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, true} = Inserting.transform(file, user)

    {:ok, file} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, true} = Inserting.transform(file, user)

    {result, list} = GettingList.get(
      %Pagination{
        page: 1,
        limit: 10
      }, 
      %Filter{
        type: "Изображение"
      }, 
      %Sort{
        created: "ASC"
      }, 
      user
    )

    leng = length(list)

    assert result == :ok
    assert leng == 2
  end

  test "Get empty list" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")
    
    {result, list} = GettingList.get(
      %Pagination{
        page: 1,
        limit: 10
      }, 
      %Filter{
        type: "Видеозапись"
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