defmodule User.UseCases.AuthenticationTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUser

  alias Core.User.UseCases.Authentication, as: UseCase

  setup_all do
    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)
    :mnesia.delete_table(:users)

    {:atomic, :ok} = :mnesia.create_table(
      :codes,
      [attributes: [:needle, :created, :code, :confirmed]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :users,
      [attributes: [:id, :email, :name, :surname, :created, :updated]]
    )

    :mnesia.add_table_index(:users, :email)

    :ok
  end

  test "Аутентификация пользователя" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    
    {result, _}  = UseCase.auth(GettingConfirmationCode, GettingUser, %{
      email: "test@gmail.com",
      code: code.code
    })

    assert result == :ok
  end

  test "Аутентификация пользователя - невалидный код" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test1@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test1@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    
    {result, _}  = UseCase.auth(GettingConfirmationCode, GettingUser, %{
      email: "test1@gmail.com",
      code: 123
    })

    assert result == :error
  end

  test "Аутентификация пользователя - код не найден" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test2@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test2@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    
    {result, _}  = UseCase.auth(GettingConfirmationCode, GettingUser, %{
      email: "test3@gmail.com",
      code: code.code
    })

    assert result == :error
  end
end