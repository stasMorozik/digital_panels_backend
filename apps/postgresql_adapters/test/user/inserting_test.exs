defmodule User.InsertingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.User.Inserting
  alias Core.User.Builder
  alias Core.User.Entity

  doctest PostgresqlAdapters.User.Inserting

  @pg_secret_key Application.compile_env(:postgresql_adapters, :secret_key, "!qazSymKeyXsw2")

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

    Postgrex.query!(pid, "DELETE FROM users WHERE pgp_sym_decrypt(email::bytea, '#{@pg_secret_key}') != 'stanim857@gmail.com'", [])

    :ok
  end

  test "Insert" do
    {:ok, user_entity} = Builder.build(%{email: "test@gmail.com", name: "Пётр", surname: "Павел"})

    {result, _} = Inserting.transform(user_entity)

    assert result == :ok
  end

  test "Invalid user" do
    {result, _} = Inserting.transform(%{})

    assert result == :error
  end

  test "Already exists" do
    {:ok, user_entity} = Builder.build(%{email: "test11@gmail.com", name: "Пётр", surname: "Павел"})

    {_, _} = Inserting.transform(user_entity)

    {result, _} = Inserting.transform(user_entity)

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
