defmodule Device.UseCases.GettingListTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUserByEmail
  alias User.FakeAdapters.GettingById, as: GettingUserById
  alias Device.FakeAdapters.GettingList, as: GettingListDevice

  alias Core.User.UseCases.Authentication, as: AuthenticationUseCase

  alias Device.FakeAdapters.Inserting, as: InsertingDevice

  alias Core.Device.UseCases.GettingList, as: UseCase

  setup_all do
    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)
    :mnesia.delete_table(:devices)
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

  test "Получение списка устройств" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, device} = Core.Device.Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    {:ok, true} = InsertingDevice.transform(device, user)
    
    {_, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test@gmail.com",
      code: code.code
    })

    {result, list} = UseCase.get(GettingUserById, GettingListDevice, %{
      pagi: %{
        page: 1,
        limit: 10
      },
      filter: %{
        ip: "192.168.1.98"
      },
      token: tokens.access_token,
    })

    assert length(list) == 1
    assert result == :ok
  end

  test "Получение списка устройств - пустой список" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test1@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test1@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, device} = Core.Device.Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    {:ok, true} = InsertingDevice.transform(device, user)
    
    {_, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test1@gmail.com",
      code: code.code
    })

    {result, list} = UseCase.get(GettingUserById, GettingListDevice, %{
      pagi: %{
        page: 1,
        limit: 10
      },
      filter: %{
        ip: "192.168.1.96"
      },
      token: tokens.access_token,
    })

    assert length(list) == 0
    assert result == :ok
  end

  test "Получение списка устройств - невалидный токен" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test2@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test2@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, device} = Core.Device.Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    {:ok, true} = InsertingDevice.transform(device, user)

    {result, list} = UseCase.get(GettingUserById, GettingListDevice, %{
      pagi: %{
        page: 1,
        limit: 10
      },
      filter: %{
        ip: "192.168.1.98"
      },
      token: "indali token",
    })

    assert result == :error
  end
end