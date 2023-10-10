defmodule ConfirmationCode.GettingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.ConfirmationCode.Inserting
  alias PostgresqlAdapters.ConfirmationCode.Getting
  alias Core.ConfirmationCode.Builder
  alias Core.Shared.Validators.Email

  doctest PostgresqlAdapters.ConfirmationCode.Getting

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

    Postgrex.query!(pid, "DELETE FROM confirmation_codes WHERE needle != 'stasmoriniv@gmail.com'", [])

    :ok
  end

  test "Get" do
    {:ok, code_entity} = Builder.build("test@gmail.com", Email)

    Inserting.transform(code_entity)

    {result, _} = Getting.get("test@gmail.com")

    assert result == :ok
  end

  test "Code not found" do
    {result, _} = Getting.get("test111@gmail.com")

    assert result == :error
  end
end
