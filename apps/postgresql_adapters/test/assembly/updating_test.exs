defmodule Assembly.UpdatingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Assembly.Inserting
  alias PostgresqlAdapters.Assembly.Updating
  alias PostgresqlAdapters.Assembly.GettingById
  alias Core.Assembly.Builder

  doctest PostgresqlAdapters.Assembly.Updating

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

    Postgrex.query!(pid, "DELETE FROM relations_user_assembly", [])
    Postgrex.query!(pid, "DELETE FROM assemblies", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_task", [])
    Postgrex.query!(pid, "DELETE FROM tasks", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_device", [])
    Postgrex.query!(pid, "DELETE FROM devices", [])

    Postgrex.query!(pid, "DELETE FROM relations_user_group", [])
    Postgrex.query!(pid, "DELETE FROM groups", [])
    
    :ok
  end

  test "Update 0" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Group.Inserting.transform(group, user)

    {:ok, assembly} = Builder.build(%{group: group, type: "Linux"})

    {:ok, true} = Inserting.transform(assembly, user)

    {result, _} = Updating.transform(assembly, user)

    assert result == :ok
  end

  test "Update 1" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Group.Inserting.transform(group, user)

    {:ok, assembly} = Builder.build(%{group: group, type: "Linux"})

    {:ok, true} = Inserting.transform(assembly, user)

    {:ok, assembly} = Core.Assembly.Editor.edit(assembly)

    {:ok, true} = Updating.transform(assembly, user)

    {:ok, assembly} = GettingById.get(assembly.id, user)

    assert assembly.status == true
  end

  test "Invalid group" do
    {result, _} = Updating.transform(%{}, %{})

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
