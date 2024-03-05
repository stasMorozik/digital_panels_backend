defmodule Playlist.GettingListTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Playlist.Inserting
  alias PostgresqlAdapters.Playlist.GettingList
  alias Core.Playlist.Builder

  alias Core.Shared.Types.Pagination
  alias Core.Playlist.Types.Filter
  alias Core.Playlist.Types.Sort

  doctest PostgresqlAdapters.Playlist.GettingList

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

    {:ok, playlist} = Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = Inserting.transform(playlist, user)

    {result, list} = GettingList.get(
      %Pagination{
        page: 1,
        limit: 10
      }, 
      %Filter{
        name: "Тест"
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