defmodule Devices.UseCases.GettingListTest do
  use ExUnit.Case

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.Device.Builder, as: DeviceBuilder
  alias Core.User.Builder, as: UserBuilder

  alias Core.User.UseCases.Authorization

  alias Core.Device.UseCases.GettingList

  setup_all do
    File.touch("/tmp/not_emty.txt", 1544519753)
    
    File.write("/tmp/not_emty.txt", "content")

    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:devices)

    :mnesia.delete_table(:users)

    :mnesia.delete_table(:playlists)

    {:atomic, :ok} = :mnesia.create_table(
      :users,
      [attributes: [:id, :email, :name, :surname, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :playlists,
      [attributes: [:id, :user_id, :name, :created, :updated]]
    )

    {:atomic, :ok} = :mnesia.create_table(
      :devices,
      [attributes: [
        :id,
        :user_id,
        :playlist_id,
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
    {:atomic, :ok} = :mnesia.add_table_index(:playlists, :name)
    {:atomic, :ok} = :mnesia.add_table_index(:devices, :ssh_host)

    :ok
  end

  test "Get list" do
    {_, user_entity} = UserBuilder.build(%{
      email: "test3@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {_, device_entity_0} = DeviceBuilder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "NY Long street 1234",
      longitude: 91.223,
      latitude: -67.99
    })

    {_, device_entity_1} = DeviceBuilder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.99",
      ssh_user: "test",
      ssh_password: "12345",
      address: "NY Long street 1234",
      longitude: 91.223,
      latitude: -67.99
    })

    {_, playlist_entity_0} = PlaylistBuilder.build(%{
      name: "test_0",
      contents: [
        %{
          file: %{
            path: "/tmp/not_emty.txt"
          },
          display_duration: 15
        }
      ],
      web_dav_url: "http://localhost"
    })

    FakeAdapters.User.Inserting.transform(user_entity)
    FakeAdapters.Device.Inserting.transform(device_entity_0, user_entity, playlist_entity_0)
    FakeAdapters.Device.Inserting.transform(device_entity_1, user_entity, playlist_entity_0)

    access_token = Core.AccessToken.Entity.generate_and_sign!(%{id: user_entity.email})

    {result, _} = GettingList.get(
      Authorization,
      FakeAdapters.User.Getter,
      FakeAdapters.Device.GetterList,
      %{
        token: access_token,
        pagination: %{
          page: 1,
          limit: 10
        },
        filter: %{
          ssh_host: "192.168.1.98"
        },
        sort: %{
          name: "test",
          created: "test",
          updated: "test"
        }
      }
    )
    
    assert result == :ok
  end

  test "Get list" do
    {_, user_entity} = UserBuilder.build(%{
      email: "test4@gmail.com", 
      name: "Пётр", 
      surname: "Павел"
    })

    {_, device_entity_0} = DeviceBuilder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.100",
      ssh_user: "test",
      ssh_password: "12345",
      address: "NY Long street 1234",
      longitude: 91.223,
      latitude: -67.99
    })

    {_, device_entity_1} = DeviceBuilder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.101",
      ssh_user: "test",
      ssh_password: "12345",
      address: "NY Long street 1234",
      longitude: 91.223,
      latitude: -67.99
    })

    {_, playlist_entity_0} = PlaylistBuilder.build(%{
      name: "test_1",
      contents: [
        %{
          file: %{
            path: "/tmp/not_emty.txt"
          },
          display_duration: 15
        }
      ],
      web_dav_url: "http://localhost"
    })

    FakeAdapters.User.Inserting.transform(user_entity)
    FakeAdapters.Device.Inserting.transform(device_entity_0, user_entity, playlist_entity_0)
    FakeAdapters.Device.Inserting.transform(device_entity_1, user_entity, playlist_entity_0)

    {result, _} = GettingList.get(
      Authorization,
      FakeAdapters.User.Getter,
      FakeAdapters.Device.GetterList,
      %{
        token: "Invalid token",
        pagination: %{
          page: 1,
          limit: 10
        },
        filter: %{
          ssh_host: "192.168.1.98"
        },
        sort: %{
          name: "test",
          created: "test",
          updated: "test"
        }
      }
    )

    assert result == :error
  end
end