defmodule Device.EditTest do
  use ExUnit.Case

  alias Core.Device.Builder
  alias Core.Device.Methods.Edit

  doctest Core.Device.Builder

  test "Edit test" do
    {_, entity} = Builder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Edit.edit(entity, %{
      ssh_port: 23,
      ssh_host: "192.168.1.97",
      ssh_user: "admin",
      ssh_password: "12346",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 55.0967,
      latitude: -55.0986,
      is_active: true,
    })
    
    assert result == :ok
  end

  test "Invalid ssh port" do
    {_, entity} = Builder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Edit.edit(entity, %{
      ssh_port: -23,
      ssh_host: "192.168.1.97",
      ssh_user: "admin",
      ssh_password: "12346",
      address: nil,
      longitude: nil,
      latitude: nil,
      is_active: true,
    })

    assert result == :error
  end

  test "Invalid ssh user" do
    {_, entity} = Builder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Edit.edit(entity, %{
      ssh_port: 23,
      ssh_host: "192.168.1.97",
      ssh_user: "test!@",
      ssh_password: "12346",
      address: nil,
      longitude: nil,
      latitude: nil,
      is_active: true,
    })

    assert result == :error
  end

  test "Invalid ssh password" do
    {_, entity} = Builder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Edit.edit(entity, %{
      ssh_port: 23,
      ssh_host: "192.168.1.97",
      ssh_user: "admin",
      ssh_password: "@#12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 55.0967,
      latitude: -55.0986,
      is_active: true,
    })
    
    assert result == :error
  end

  test "Invalid address" do
    {_, entity} = Builder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Edit.edit(entity, %{
      ssh_port: 23,
      ssh_host: "192.168.1.97",
      ssh_user: "admin",
      ssh_password: "12345",
      address: -1,
      longitude: 55.0967,
      latitude: -55.0986,
      is_active: true,
    })
    
    assert result == :error
  end

  test "Invalid longitude" do
    {_, entity} = Builder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Edit.edit(entity, %{
      ssh_port: 23,
      ssh_host: "192.168.1.97",
      ssh_user: "admin",
      ssh_password: "@#12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: -191.223,
      latitude: -55.0986,
      is_active: true,
    })
    
    assert result == :error
  end

  test "Invalid latitude" do
    {_, entity} = Builder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Edit.edit(entity, %{
      ssh_port: 23,
      ssh_host: "192.168.1.97",
      ssh_user: "admin",
      ssh_password: "@#12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -555.0986,
      is_active: true,
    })
    
    assert result == :error
  end

  test "Invalid is active" do
    {_, entity} = Builder.build(%{
      ssh_port: 22,
      ssh_host: "192.168.1.98",
      ssh_user: "test",
      ssh_password: "12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -67.99
    })

    {result, _} = Edit.edit(entity, %{
      ssh_port: 23,
      ssh_host: "192.168.1.97",
      ssh_user: "admin",
      ssh_password: "@#12345",
      address: "Москва Ветка метро Замоскворецкая",
      longitude: 91.223,
      latitude: -55.0986,
      is_active: "true",
    })
    
    assert result == :error
  end
end