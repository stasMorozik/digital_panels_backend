defmodule User.UseCases.AuthenticationTest do
  use ExUnit.Case

  alias Core.User.UseCases.Registration
  alias Core.User.UseCases.Authentication
  alias Core.ConfirmationCode.Builder
  alias Core.Shared.Validators.Email

  doctest Core.User.UseCases.Authentication

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

  test "Authentication" do
    {_, confirmation_code} = Builder.build("ivan_sm@gmail.com", Email)

    confirmation_code = Map.put(confirmation_code, :confirmed, true)

    {:ok, _} = FakeAdapters.ConfirmationCode.Inserting.transform(confirmation_code)

    args = %{
      email: "ivan_sm@gmail.com",
      name: "Иван",
      surname: "Смоленский"
    }

    {:ok, _} = Registration.reg(
      FakeAdapters.User.Inserting,
      FakeAdapters.ConfirmationCode.Getter,
      FakeAdapters.Shared.Notifier,
      args
    )

    {_, confirmation_code} = Builder.build("ivan_sm@gmail.com", Email)

    confirmation_code = Map.put(confirmation_code, :confirmed, true)

    {:ok, _} = FakeAdapters.ConfirmationCode.Inserting.transform(confirmation_code)

    args = %{email: "ivan_sm@gmail.com"}

    {result, _} = Authentication.auth(
      FakeAdapters.ConfirmationCode.Getter,
      FakeAdapters.User.Getter,
      args
    )

    assert result == :ok
  end
end
