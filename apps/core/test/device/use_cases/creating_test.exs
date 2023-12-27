defmodule Device.UseCases.CreatingTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUserByEmail
  alias User.FakeAdapters.GettingById, as: GettingUserById

  alias Core.User.UseCases.Authentication, as: AuthenticationUseCase
  alias Core.User.UseCases.Authorization, as: AuthorizationUseCase

  alias Device.FakeAdapters.Inserting, as: InsertingDevice

  alias Core.Device.UseCases.Creating, as: UseCase

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

    {:atomic, :ok} = :mnesia.create_table(
      :devices,
      [attributes: [:id, :ip, :latitude, :longitude, :created, :updated]]
    )

    :mnesia.add_table_index(:users, :email)
    :mnesia.add_table_index(:devices, :ip)

    :ok
  end

  test "Создание устройства" do
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
    
    {_, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test@gmail.com",
      code: code.code
    })

    {result, _} = UseCase.create(GettingUserById, InsertingDevice, %{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      token: tokens.access_token
    })

    assert result == :ok
  end
end