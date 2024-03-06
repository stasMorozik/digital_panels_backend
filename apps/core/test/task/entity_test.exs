defmodule Task.EntityTest do
  use ExUnit.Case

  alias Core.Task.Builder, as: TaskBuilder
  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.Group.Builder, as: GroupBuilder

  test "Построение сущности" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 1,
      end_hour: 5,
      start_minute: 0,
      end_minute: 30
    })

    assert result == :ok
  end

  test "Построение сущности - 1" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 24,
      end_hour: 1,
      start_minute: 0,
      end_minute: 30
    })

    assert result == :ok
  end

  test "Построение сущности - 2" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 24,
      end_hour: 24,
      start_minute: 0,
      end_minute: 30
    })

    assert result == :ok
  end

  test "Построение сущности - не валидное название" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234@",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 1,
      end_hour: 2,
      start_minute: 0,
      end_minute: 30
    })

    assert result == :error
  end

  test "Построение сущности - не валидный тип" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день!",
      day: nil, 
      start_hour: 1,
      end_hour: 2,
      start_minute: 0,
      end_minute: 30
    })

    assert result == :error
  end

  test "Построение сущности - не валидный день" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: 1, 
      start_hour: 1,
      end_hour: 2,
      start_minute: 0,
      end_minute: 30
    })

    assert result == :error
  end

  test "Построение сущности - не валидные часы старта" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: -1,
      end_hour: 2,
      start_minute: 0,
      end_minute: 30
    })

    assert result == :error
  end

  test "Построение сущности - не валидные часы конца" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 1,
      end_hour: -2,
      start_minute: 0,
      end_minute: 30
    })

    assert result == :error
  end

  test "Построение сущности - не валидные минуты начала" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 1,
      end_hour: 2,
      start_minute: -10,
      end_minute: 30
    })

    assert result == :error
  end

  test "Построение сущности - не валидные минуты конца" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 1,
      end_hour: 2,
      start_minute: 10,
      end_minute: -30
    })

    assert result == :error
  end

  test "Построение сущности - не валидные час начала и конца" do
    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {result, _} = TaskBuilder.build(%{
      name: "Тест_1234",
      playlist: playlist,
      group: group,
      type: "Каждый день",
      day: nil, 
      start_hour: 2,
      end_hour: 1,
      start_minute: 10,
      end_minute: 30
    })

    assert result == :error
  end
end