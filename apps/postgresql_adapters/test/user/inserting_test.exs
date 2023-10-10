defmodule User.InsertingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.User.Inserting
  alias Core.User.Builder

  doctest PostgresqlAdapters.User.Inserting

  setup_all do
    :ets.new(:connections, [:set, :public, :named_table])

    {:ok, pid} = Postgrex.start_link(
      hostname: "192.168.0.106",
      username: "db_user",
      password: "12345",
      database: "system_content_manager",
      port: 5437
    )

    :ets.insert(:connections, {"postgresql", "", pid})

    Postgrex.query!(pid, "DELETE FROM devices", [])
    Postgrex.query!(pid, "DELETE FROM users WHERE email != 'stasmoriniv@gmail.com'", [])

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
end
