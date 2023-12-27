defmodule Device.EntityTest do
  use ExUnit.Case

  alias Core.Device.Builder
  alias Core.Device.Editor

  test "Построение сущности" do
    {result, _} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    assert result == :ok
  end

  test "Построение сущности - невалидный ip" do
    {result, _} = Builder.build(%{
      ip: "192.168.1.",
      latitude: 78.454567,
      longitude: 98.3454
    })

    assert result == :error
  end

  test "Построение сущности - невалидная широта" do
    {result, _} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: -91,
      longitude: 98.3454
    })

    assert result == :error
  end

  test "Построение сущности - невалидная долгота" do
    {result, _} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: -181
    })

    assert result == :error
  end

  test "Построение сущности - невалидные данные" do
    {result, _} = Builder.build(%{})

    assert result == :error
  end

  test "Редактирование сущности" do
    {_, entity} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {result, entity} = Editor.edit(entity, %{
      ip: "192.168.1.99",
      latitude: 78.454568,
      longitude: 98.3455
    })

    assert result == :ok
    assert entity.ip == "192.168.1.99"
    assert entity.latitude == 78.454568
    assert entity.longitude == 98.3455
  end

  test "Редактирование сущности - только ip" do
    {_, entity} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {result, entity} = Editor.edit(entity, %{
      ip: "192.168.1.99"
    })

    assert result == :ok
    assert entity.ip == "192.168.1.99"
  end

  test "Редактирование сущности - только широта" do
    {_, entity} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {result, entity} = Editor.edit(entity, %{
      latitude: 78.454568,
    })

    assert result == :ok
    assert entity.latitude == 78.454568
  end

  test "Редактирование сущности - только долгота" do
    {_, entity} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {result, entity} = Editor.edit(entity, %{
      longitude: 98.3455
    })

    assert result == :ok
    assert entity.longitude == 98.3455
  end

  test "Редактирование сущности - не валидные данные" do
    {result, _} = Editor.edit(%{}, %{})

    assert result == :error
  end

  test "Редактирование сущности - невалидный ip" do
    {_, entity} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {result, _} = Editor.edit(entity, %{
      ip: "192.168.1."
    })

    assert result == :error
  end

  test "Редактирование сущности - невалидная широта" do
    {_, entity} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {result, _} = Editor.edit(entity, %{
      latitude: -91
    })

    assert result == :error
  end

  test "Редактирование сущности - невалидная долгота" do
    {_, entity} = Builder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454
    })

    {result, _} = Editor.edit(entity, %{
      longitude: -181
    })

    assert result == :error
  end
end