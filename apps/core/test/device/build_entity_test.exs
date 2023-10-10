defmodule Device.BuildEntityTest do
  use ExUnit.Case

  alias Core.Device.Builder

  doctest Core.Device.Builder

  test "Build device 1" do
    {result, _} =
      Builder.build(%{
        ssh_port: 22,
        ssh_host: "192.168.1.98",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 1234",
        longitude: 91.223,
        latitude: -67.99
      })

    assert result == :ok
  end

  test "Build device 2" do
    {result, _} =
      Builder.build(%{
        ssh_port: 22,
        ssh_host: "192.168.1.98",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 1234",
        longitude: -91.223,
        latitude: 67.99
      })

    assert result == :ok
  end

  test "Invalid ssh port" do
    {result, _} =
      Builder.build(%{
        ssh_port: -22,
        ssh_host: "192.168.1.98",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 1234",
        longitude: 91.223,
        latitude: -67.99
      })

    assert result == :error
  end

  test "Invalid ssh host" do
    {result, _} =
      Builder.build(%{
        ssh_port: 22,
        ssh_host: "!test",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 1234",
        longitude: 91.223,
        latitude: -67.99
      })

    assert result == :error
  end

  test "Invalid ssh user" do
    {result, _} =
      Builder.build(%{
        ssh_port: 22,
        ssh_host: "192.168.1.98",
        ssh_user: "test!@",
        ssh_password: "12345",
        address: "NY Long street 1234",
        longitude: 91.223,
        latitude: -67.99
      })

    assert result == :error
  end

  test "Invalid ssh password" do
    {result, _} =
      Builder.build(%{
        ssh_port: 22,
        ssh_host: "192.168.1.98",
        ssh_user: "test",
        ssh_password: "@#12345",
        address: "NY Long street 1234",
        longitude: 91.223,
        latitude: -67.99
      })

    assert result == :error
  end

  test "Invalid address" do
    {result, _} =
      Builder.build(%{
        ssh_port: 22,
        ssh_host: "192.168.1.98",
        ssh_user: "test",
        ssh_password: "12345",
        address: nil,
        longitude: 91.223,
        latitude: -67.99
      })

    assert result == :error
  end

  test "Invalid longitude" do
    {result, _} =
      Builder.build(%{
        ssh_port: 22,
        ssh_host: "192.168.1.98",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 1234",
        longitude: -191.223,
        latitude: -67.99
      })

    assert result == :error
  end

  test "Invalid latitude" do
    {result, _} =
      Builder.build(%{
        ssh_port: 22,
        ssh_host: "192.168.1.98",
        ssh_user: "test",
        ssh_password: "12345",
        address: "NY Long street 1234",
        longitude: 91.223,
        latitude: 97.99
      })

    assert result == :error
  end
end
