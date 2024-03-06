defmodule Assembly.GettingListTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Assembly.Inserting
  alias PostgresqlAdapters.Assembly.GettingList
  alias Core.Assembly.Builder

  alias Core.Shared.Types.Pagination
  alias Core.Assembly.Types.Filter
  alias Core.Assembly.Types.Sort

  doctest PostgresqlAdapters.Assembly.GettingList

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

  test "Get not empty list" do
    {:ok, user} = PostgresqlAdapters.User.GettingByEmail.get("stanim857@gmail.com")

    {:ok, group} = Core.Group.Builder.build(%{
      name: "Тест"
    })

    {:ok, true} = PostgresqlAdapters.Group.Inserting.transform(group, user)

    {:ok, assembly} = Builder.build(%{group: group, type: "Linux"})

    {:ok, true} = Inserting.transform(assembly, user)

    {result, list} = GettingList.get(
      %Pagination{
        page: 1,
        limit: 10
      }, 
      %Filter{
        type: "Linux"
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
        type: "Windows"
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