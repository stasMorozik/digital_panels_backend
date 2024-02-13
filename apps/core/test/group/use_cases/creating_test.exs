defmodule Group.UseCases.CreatingTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUserByEmail
  alias User.FakeAdapters.GettingById, as: GettingUserById

  alias Core.Device.Builder, as: DeviceBuilder
  alias Device.FakeAdapters.Inserting, as: InsertingDevice
  alias Device.FakeAdapters.GettingList, as: GettingListDevice

  alias Group.FakeAdapters.Inserting, as: InsertingGroup

  alias Core.User.UseCases.Authentication, as: AuthenticationUseCase

  alias Core.Group.UseCases.Creating, as: UseCase

  setup_all do
    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)
    :mnesia.delete_table(:users)
    :mnesia.delete_table(:devices)
    :mnesia.delete_table(:groups)

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

    {:atomic, :ok} = :mnesia.create_table(
      :groups,
      [attributes: [:id, :name, :sum, :devices, :created, :updated]]
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
    
    {:ok, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test@gmail.com",
      code: code.code
    })

    {:ok, device} = DeviceBuilder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание"
    })

    {:ok, true} = InsertingDevice.transform(device, user)

    {result, _} = UseCase.create(GettingUserById, GettingListDevice, InsertingGroup, %{
      pagi: %{
        page: 1,
        limit: 10
      },
      filter: %{
        ip: "192.168.1.98"
      },
      sort: %{},
      name: "Тест_1234",
      token: tokens.access_token
    })

    assert result == :ok
  end

  test "Создание устройства - не валидный список устройств" do
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
    
    {:ok, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test@gmail.com",
      code: code.code
    })

    {:ok, device} = DeviceBuilder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание"
    })

    {:ok, true} = InsertingDevice.transform(device, user)

    {result, _} = UseCase.create(GettingUserById, GettingListDevice, InsertingGroup, %{
      pagi: %{
        page: 1,
        limit: 10
      },
      filter: %{
        ip: "192.168.1.97"
      },
      sort: %{},
      name: "Тест_1234",
      token: tokens.access_token
    })

    assert result == :error
  end

  test "Создание устройства - не валидный токен" do
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

    {:ok, device} = DeviceBuilder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание"
    })

    {:ok, true} = InsertingDevice.transform(device, user)

    {result, _} = UseCase.create(GettingUserById, GettingListDevice, InsertingGroup, %{
      pagi: %{
        page: 1,
        limit: 10
      },
      filter: %{
        ip: "192.168.1.98"
      },
      sort: %{},
      name: "Тест_1234",
      token: "invalid_token"
    })

    assert result == :error
  end
end