defmodule User.GettingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.User.Inserting
  alias PostgresqlAdapters.User.Getting
  alias Core.User.Builder

  doctest PostgresqlAdapters.User.Getting

  setup_all do
    :ets.new(:connections, [:set, :public, :named_table])

    {:ok, pid} = Postgrex.start_link(
      hostname: "192.168.0.161",
      username: "db_user",
      password: "12345",
      database: "system_content_manager",
      port: 5437
    )

    :ets.insert(:connections, {"postgresql", "", pid})

    Postgrex.query!(pid, "DELETE FROM relations_user_playlist", [])
    Postgrex.query!(pid, "DELETE FROM relations_user_device", [])
    Postgrex.query!(pid, "DELETE FROM relations_playlist_device", [])

    Postgrex.query!(pid, "DELETE FROM devices", [])
    Postgrex.query!(pid, "DELETE FROM users WHERE email != 'stasmoriniv@gmail.com'", [])

    :ok
  end

  test "Get" do
    {:ok, user_entity} = Builder.build(%{email: "test@gmail.com", name: "Пётр", surname: "Павел"})

    Inserting.transform(user_entity)

    {result, _} = Getting.get("test@gmail.com")

    assert result == :ok
  end

  test "User not found" do
    {result, _} = Getting.get("test111@gmail.com")

    assert result == :error
  end
end
