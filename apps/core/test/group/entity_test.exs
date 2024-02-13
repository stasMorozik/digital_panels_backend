defmodule Group.EntityTest do
  use ExUnit.Case

  alias Core.Group.Builder, as: GroupBuilder
  alias Core.Device.Builder, as: DeviceBuilder

  test "Построение сущности" do
    {:ok, device} = DeviceBuilder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание"
    })

    {result, _} = GroupBuilder.build(%{
      name: "Тест",
      devices: [device]
    })

    assert result == :ok
  end

  test "Построение сущности - невалидное название" do
    {:ok, device} = DeviceBuilder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание"
    })

    {result, _} = GroupBuilder.build(%{
      name: "Тест@",
      devices: [device]
    })

    assert result == :error
  end

  test "Построение сущности - невалидный список устройств" do
    {result, _} = GroupBuilder.build(%{
      name: "Тест",
      devices: []
    })

    assert result == :error
  end
end