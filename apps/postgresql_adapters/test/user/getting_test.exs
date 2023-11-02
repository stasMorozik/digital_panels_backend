defmodule User.GettingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.User.Inserting
  alias PostgresqlAdapters.User.Getting
  alias PostgresqlAdapters.User.GettingById
  alias Core.User.Builder

  doctest PostgresqlAdapters.User.Getting
  doctest PostgresqlAdapters.User.GettingById

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
    Postgrex.query!(pid, "DELETE FROM relations_user_device", [])
    Postgrex.query!(pid, "DELETE FROM relations_playlist_device", [])

    Postgrex.query!(pid, "DELETE FROM devices", [])
    Postgrex.query!(pid, "DELETE FROM users WHERE email != 'stasmoriniv@gmail.com'", [])

    :ok
  end

  test "Get by email" do
    {:ok, user_entity} = Builder.build(%{email: "test@gmail.com", name: "Пётр", surname: "Павел"})

    Inserting.transform(user_entity)

    {result, _} = Getting.get("test@gmail.com")

    assert result == :ok
  end

  test "Get by id" do
    {:ok, user_entity} = Builder.build(%{email: "test12@gmail.com", name: "Пётр", surname: "Павел"})

    Inserting.transform(user_entity)

    {result, _} = GettingById.get(UUID.string_to_binary!(user_entity.id))

    assert result == :ok
  end

  test "User not found" do
    {result, _} = Getting.get("test111@gmail.com")

    assert result == :error
  end

  test "Exception" do
    {:ok, user_entity} = Builder.build(%{email: "test123@gmail.com", name: "Пётр", surname: "Павел"})

    Inserting.transform(user_entity)

    {result, _} = GettingById.get(<<104, 101, 197, 130, 197, 130, 60, 158, 104, 101, 197, 130, 197, 130, 46, 90>>)

    assert result == :error
  end
end
