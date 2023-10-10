defmodule Device.UseCases.CreatingTest do
  use ExUnit.Case

  alias FakeAdapters.Device.Inserting, as: InsertingDevice
  alias FakeAdapters.User.Getter, as: GetterUser

  alias Core.User.UseCases.Authorization
  alias Core.User.Builder

  alias Core.Device.UseCases.Creating

  setup_all do

    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:devices)

    :mnesia.delete_table(:users)

    {:atomic, :ok} = :mnesia.create_table(
      :users,
      [attributes: [:id, :email, :name, :surname, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :devices,
      [attributes: [
        :id,
        :user_id,
        :ssh_port,
        :ssh_host,
        :ssh_user,
        :ssh_password,
        :address,
        :longitude,
        :latitude,
        :created,
        :updated
      ]]
    )

    {:atomic, :ok} = :mnesia.add_table_index(:users, :email)

    :ok
  end

  test "Create" do
    {_, user_entity} = Builder.build(%{email: "test3@gmail.com", name: "Пётр", surname: "Павел"})

    FakeAdapters.User.Inserting.transform(user_entity)

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.email})

    {result, _} = Creating.create(
      Authorization,
      GetterUser,
      InsertingDevice,
      %{
        token: access_token,
        ssh_port: 22,
        ssh_host: "192.168.1.22",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 123",
        longitude: 91.223,
        latitude: -67.99
      }
    )

    assert result == :ok
  end

  test "Invalid token" do
    {_, user_entity} = Builder.build(%{email: "test3@gmail.com", name: "Пётр", surname: "Павел"})

    FakeAdapters.User.Inserting.transform(user_entity)

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.email})

    {result, _} = Creating.create(
      Authorization,
      GetterUser,
      InsertingDevice,
      %{
        token: "invalid token",
        ssh_port: 22,
        ssh_host: "192.168.1.22",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 123",
        longitude: 91.223,
        latitude: -67.99
      }
    )

    assert result == :error
  end

  test "Invalid port" do
    {_, user_entity} = Builder.build(%{email: "test3@gmail.com", name: "Пётр", surname: "Павел"})

    FakeAdapters.User.Inserting.transform(user_entity)

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.email})

    {result, _} = Creating.create(
      Authorization,
      GetterUser,
      InsertingDevice,
      %{
        token: access_token,
        ssh_port: -22,
        ssh_host: "192.168.1.22",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 123",
        longitude: 91.223,
        latitude: -67.99
      }
    )

    assert result == :error
  end
end
