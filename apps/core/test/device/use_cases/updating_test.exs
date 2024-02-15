defmodule Device.UseCases.UpdatingTest do
  use ExUnit.Case

  alias User.FakeAdapters.Inserting, as: InsertingUser
  alias ConfirmationCode.FakeAdapters.Inserting, as: InsertingConfirmationCode

  alias ConfirmationCode.FakeAdapters.Getting, as: GettingConfirmationCode
  alias User.FakeAdapters.GettingByEmail, as: GettingUserByEmail
  alias User.FakeAdapters.GettingById, as: GettingUserById
  alias Device.FakeAdapters.Getting, as: GettingDevice

  alias Core.Group.Builder, as: GroupBuilder
  alias Group.FakeAdapters.Inserting, as: InsertingGroup
  alias Group.FakeAdapters.Getting, as: GettingGroup

  alias Core.User.UseCases.Authentication, as: AuthenticationUseCase

  alias Device.FakeAdapters.Inserting, as: InsertingDevice

  alias Core.Device.UseCases.Updating, as: UseCase

  setup_all do
    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)
    :mnesia.delete_table(:devices)
    :mnesia.delete_table(:users)
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
      [attributes: [:id, :ip, :latitude, :longitude, :group, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :groups,
      [attributes: [:id, :name, :sum, :devices, :created, :updated]]
    )

    :mnesia.add_table_index(:users, :email)
    :mnesia.add_table_index(:devices, :ip)

    :ok
  end

  test "Обновление устройства" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, true} = InsertingGroup.transform(group, user)

    {:ok, device} = Core.Device.Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание",
      group: group
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    {:ok, true} = InsertingDevice.transform(device, user)
    
    {:ok, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test@gmail.com",
      code: code.code
    })

    {result, _} = UseCase.update(GettingUserById, GettingGroup, GettingDevice, InsertingDevice, %{
      ip: "192.168.1.97",
      latitude: 78.454568,
      longitude: 98.3453,
      desc: "Описание",
      token: tokens.access_token,
      id: device.id,
      group_id: group.id
    })

    assert result == :ok
  end

  test "Обновление устройства - устройство не найдено" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test1@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test1@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, true} = InsertingGroup.transform(group, user)

    {:ok, device_0} = Core.Device.Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание",
      group: group
    })

    {:ok, device_1} = Core.Device.Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание",
      group: group
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    {:ok, true} = InsertingDevice.transform(device_0, user)
    
    {_, tokens}  = AuthenticationUseCase.auth(GettingConfirmationCode, GettingUserByEmail, %{
      email: "test1@gmail.com",
      code: code.code
    })

    {result, _} = UseCase.update(GettingUserById, GettingDevice, InsertingDevice, %{
      ip: "192.168.1.97",
      latitude: 78.454568,
      longitude: 98.3453,
      desc: "Описание",
      token: tokens.access_token,
      id: device_1.id,
      group_id: group.id
    })

    assert result == :error
  end

  test "Обновление устройства - невалидный токен" do
    {:ok, code} = Core.ConfirmationCode.Builder.build(
      Core.Shared.Validators.Email, "test2@gmail.com"
    )

    {:ok, user} = Core.User.Builder.build(%{
      email: "test2@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, true} = InsertingGroup.transform(group, user)

    {:ok, device} = Core.Device.Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание",
      group: group
    })

    {:ok, true} = InsertingConfirmationCode.transform(code)
    {:ok, true} = InsertingUser.transform(user)
    {:ok, true} = InsertingDevice.transform(device, user)

    {result, _} = UseCase.update(GettingUserById, GettingDevice, InsertingDevice, %{
      ip: "192.168.1.97",
      latitude: 78.454568,
      longitude: 98.3453,
      desc: "Описание",
      token: "invalid token",
      id: device.id,
      group_id: group.id
    })

    assert result == :error
  end
end