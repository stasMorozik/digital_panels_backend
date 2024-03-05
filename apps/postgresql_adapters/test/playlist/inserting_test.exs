defmodule Playlist.InsertingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Playlist.Inserting
  alias Core.Playlist.Builder

  doctest PostgresqlAdapters.Playlist.Inserting

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

    Postgrex.query!(pid, "DELETE FROM relations_user_playlist", [])
    Postgrex.query!(pid, "DELETE FROM playlists", [])
    
    :ok
  end

  test "Insert" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, playlist} = Builder.build(%{
      name: "Тест"
    })

    {result, _} = Inserting.transform(playlist, user)

    assert result == :ok
  end

  test "Invalid playlist" do
    {result, _} = Inserting.transform(%{}, %{})

    assert result == :error
  end

  test "Already exists" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, playlist} = Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = Inserting.transform(playlist, user)

    {result, _} = Inserting.transform(playlist, user)

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