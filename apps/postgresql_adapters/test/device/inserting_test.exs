defmodule Device.InsertingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Device.Inserting
  alias Core.Device.Builder

  doctest PostgresqlAdapters.Device.Inserting

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

  test "Insert" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Group.Inserting.transform(group, user)

    {:ok, device} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание",
      group: group
    })

    {result, _} = Inserting.transform(device, user)

    assert result == :ok
  end

  test "Invalid device" do
    {result, _} = Inserting.transform(%{}, %{})

    assert result == :error
  end

  test "Already exists" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Group.Inserting.transform(group, user)

    {:ok, device} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание",
      group: group
    })

    {:ok, true} = Inserting.transform(device, user)

    {result, _} = Inserting.transform(device, user)

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
