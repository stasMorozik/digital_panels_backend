defmodule User.UseCases.RegistrationTest do
  use ExUnit.Case

  alias Core.User.UseCases.Registration
  alias Core.ConfirmationCode.Builder
  alias Core.Shared.Validators.Email

  doctest Core.User.UseCases.Registration

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

  test "Registration" do
    {_, confirmation_code} = Builder.build("ivan_sm@gmail.com", Email)

    confirmation_code = Map.put(confirmation_code, :confirmed, true)

    {:ok, _} = FakeAdapters.ConfirmationCode.Inserting.transform(confirmation_code)

    {result, _} = Registration.reg(
      FakeAdapters.User.Inserting,
      FakeAdapters.ConfirmationCode.Getter,
      FakeAdapters.Shared.Notifier,
      %{
        email: "ivan_sm@gmail.com",
        name: "Иван",
        surname: "Смоленский"
      }
    )

    assert result == :ok
  end

  test "Not found confirmation code" do

    {result, _} = Registration.reg(
      FakeAdapters.User.Inserting,
      FakeAdapters.ConfirmationCode.Getter,
      FakeAdapters.Shared.Notifier,
      %{
        email: "ivan@gmail.com",
        name: "Иван",
        surname: "Смоленский"
      }
    )

    assert result == :error

  end
end
