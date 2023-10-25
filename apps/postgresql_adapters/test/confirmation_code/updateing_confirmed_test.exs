defmodule ConfirmationCode.UpdateingConfirmedTest do
  use ExUnit.Case

  alias PostgresqlAdapters.ConfirmationCode.UpdatingConfirmed
  alias PostgresqlAdapters.ConfirmationCode.Inserting
  alias Core.ConfirmationCode.Builder
  alias Core.Shared.Validators.Email

  doctest PostgresqlAdapters.ConfirmationCode.UpdatingConfirmed

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

    Postgrex.query!(pid, "DELETE FROM confirmation_codes WHERE needle != 'stasmoriniv@gmail.com'", [])

    :ok
  end

  test "Insert" do
    {:ok, code_entity} = Builder.build("test@gmail.com", Email)

    Inserting.transform(code_entity)

    code_entity = Map.put(code_entity, :confirmed, true)

    {result, _} = UpdatingConfirmed.transform(code_entity)

    assert result == :ok
  end

  test "Invalid code" do
    {result, _} = Inserting.transform(%{})

    assert result == :error
  end
end
