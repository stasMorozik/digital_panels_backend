defmodule Playlist.GettingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Playlist.Inserting
  alias PostgresqlAdapters.Playlist.GettingById
  alias Core.Playlist.Builder

  doctest PostgresqlAdapters.Playlist.GettingById

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

  test "Get by id" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, playlist} = Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = Inserting.transform(playlist, user)
    
    {result, _} = GettingById.get(playlist.id, user)

    assert result == :ok
    # assert length(g.devices) == 1
  end

  test "Playlist not found with id" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, playlist} = Builder.build(%{
      name: "Тест"
    })

    {result, _} = GettingById.get(playlist.id, user)

    assert result == :error
  end

  test "Playlist not found with id of user" do
    {:ok, user_0} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, user_1} = Core.User.Builder.build(%{
      email: "test@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {:ok, playlist} = Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = Inserting.transform(playlist, user_0)

    {result, _} = GettingById.get(playlist.id, user_1)

    assert result == :error
  end

  # test "Exception" do
  #   {:ok, user_entity} = Builder.build(%{email: "test123@gmail.com", name: "Пётр", surname: "Павел"})

  #   Inserting.transform(user_entity)

  #   {result, _} = GettingById.get(<<104, 101, 197, 130, 197, 130, 60, 158, 104, 101, 197, 130, 197, 130, 46, 90>>)

  #   assert result == :error
  # end
end
