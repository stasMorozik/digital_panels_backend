defmodule User.UseCases.RegistrationTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode
  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias Shared.FakeAdapters.Notifier

  alias Core.User.UseCases.Registration, as: UseCase

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

    :ok
  end

  test "Регистрация пользователя" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test@gmail.com"
    )

    {:ok, true} = InsertingConfirmationCode.transform(code)
    
    {result, _}  = UseCase.reg(InsertingUser, GettingConfirmationCode, Notifier, %{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
      code: code.code
    })

    assert result == :ok
  end

  test "Регистрация пользователя - не верный код" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test1@gmail.com"
    )

    {:ok, true} = InsertingConfirmationCode.transform(code)
    
    {result, _}  = UseCase.reg(InsertingUser, GettingConfirmationCode, Notifier, %{
      email: "test1@gmail.com",
      name: "Тест",
      surname: "Тестович",
      code: 123
    })

    assert result == :error
  end

  test "Регистрация пользователя - код не найден" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test2@gmail.com"
    )

    {:ok, true} = InsertingConfirmationCode.transform(code)
    
    {result, _}  = UseCase.reg(InsertingUser, GettingConfirmationCode, Notifier, %{
      email: "test3@gmail.com",
      name: "Тест",
      surname: "Тестович",
      code: code.code
    })

    assert result == :error
  end
end