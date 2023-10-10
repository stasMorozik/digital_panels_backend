defmodule Device.InsertingTest do
  use ExUnit.Case

  alias PostgresqlAdapters.Device.Inserting, as: DeviceInserting
  alias PostgresqlAdapters.User.Inserting, as: UserInserting

  alias Core.Device.Builder, as: DeviceBuilder
  alias Core.User.Builder, as: UserBuilder

  doctest PostgresqlAdapters.Device.Inserting

  setup_all do
    :ets.new(:connections, [:set, :public, :named_table])

    {:ok, pid} = Postgrex.start_link(
      hostname: "192.168.0.106",
      username: "db_user",
      password: "12345",
      database: "system_content_manager",
      port: 5437
    )

    :ets.insert(:connections, {"postgresql", "", pid})

    Postgrex.query!(pid, "DELETE FROM devices", [])
    Postgrex.query!(pid, "DELETE FROM users WHERE email != 'stasmoriniv@gmail.com'", [])

    :ok
  end

  test "Insert" do
    {:ok, user_entity} = UserBuilder.build(%{email: "test@gmail.com", name: "Пётр", surname: "Павел"})

    {:ok, device_entity} = DeviceBuilder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "NY Long street 1234",
      longitude: 91.223,
      latitude: -67.99
    })

    {_, _} = UserInserting.transform(user_entity)

    {result, _} = DeviceInserting.transform(device_entity, user_entity)

    assert result == :ok
  end

  test "Invalid data" do
    {result, _} = DeviceInserting.transform(nil, nil)

    assert result == :error
  end
end
