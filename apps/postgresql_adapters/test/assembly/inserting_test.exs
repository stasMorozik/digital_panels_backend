defmodule Assembly.InsertingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Assembly.Inserting
  alias Core.Assembly.Builder

  doctest PostgresqlAdapters.Assembly.Inserting

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

  test "Insert" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Group.Inserting.transform(group, user)

    {:ok, assembly} = Builder.build(%{group: group, type: "Linux"})

    {result, _} = Inserting.transform(assembly, user)

    assert result == :ok
  end

  test "Invalid group" do
    {result, _} = Inserting.transform(%{}, %{})

    assert result == :error
  end

  # test "Already exists" do
  #   {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

  #   {:ok, group} = Builder.build(%{
  #     name: "Тест"
  #   })

  #   {:ok, true} = Inserting.transform(group, user)

  #   {result, _} = Inserting.transform(group, user)

  #   assert result == :error
  # end

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
