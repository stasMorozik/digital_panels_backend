defmodule Group.GettingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Group.Inserting
  alias PostgresqlAdapters.Group.GettingById
  alias Core.Group.Builder

  doctest PostgresqlAdapters.Group.GettingById

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

    Postgrex.query!(pid, "DELETE FROM relations_user_device", [])
    Postgrex.query!(pid, "DELETE FROM devices", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_group", [])
    Postgrex.query!(pid, "DELETE FROM groups", [])

    :ok
  end

  test "Get by id" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = Inserting.transform(group, user)

    {:ok, device} = Core.Device.Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание",
      group: group
    })

    {:ok, true} = PostgresqlAdapters.Device.Inserting.transform(device, user)
    
    {result, g} = GettingById.get(group.id, user)

    assert result == :ok
    assert length(g.devices) == 1
  end

  test "Group not found with id" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Builder.build(%{
      name: "Тест"
    })

    {result, _} = GettingById.get(group.id, user)

    assert result == :error
  end

  test "Group not found with id of user" do
    {:ok, user_0} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, user_1} = Core.User.Builder.build(%{
      email: "test@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {:ok, group} = Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = Inserting.transform(group, user_0)

    {result, _} = GettingById.get(group.id, user_1)

    assert result == :error
  end

  # test "Exception" do
  #   {:ok, user_entity} = Builder.build(%{email: "test123@gmail.com", name: "Пётр", surname: "Павел"})

  #   Inserting.transform(user_entity)

  #   {result, _} = GettingById.get(<<104, 101, 197, 130, 197, 130, 60, 158, 104, 101, 197, 130, 197, 130, 46, 90>>)

  #   assert result == :error
  # end
end
