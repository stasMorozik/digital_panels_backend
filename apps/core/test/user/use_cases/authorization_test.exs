defmodule User.UseCases.AuthorizationTest do
  use ExUnit.Case

  alias Core.User.UseCases.Authorization
  alias Core.User.Builder

  doctest Core.User.UseCases.Authorization

  setup_all do

    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)

    :mnesia.delete_table(:users)

    {:atomic, :ok} = :mnesia.create_table(
      :codes,
      [attributes: [:email, :created, :code, :confirmed]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :users,
      [attributes: [:id, :email, :name, :surname, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.add_table_index(:users, :email)

    :ok
  end

  test "Authorization" do
    {_, user_entity} = Builder.build(%{email: "test23@gmail.com", name: "Пётр", surname: "Павел"})

    FakeAdapters.User.Inserting.transform(user_entity)

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.email})

    {result, _} = Authorization.auth(FakeAdapters.User.Getter, %{token: access_token})

    assert result == :ok
  end

  test "Invalid Token" do
    {_, user_entity} = Builder.build(%{email: "test233@gmail.com", name: "Пётр", surname: "Павел"})

    FakeAdapters.User.Inserting.transform(user_entity)

    {result, _} = Authorization.auth(FakeAdapters.User.Getter, %{token: ""})

    assert result == :error
  end

  test "Emty Token" do
    {_, user_entity} = Builder.build(%{email: "test233@gmail.com", name: "Пётр", surname: "Павел"})

    FakeAdapters.User.Inserting.transform(user_entity)

    {result, _} = Authorization.auth(FakeAdapters.User.Getter, %{token: nil})

    assert result == :error
  end
end
