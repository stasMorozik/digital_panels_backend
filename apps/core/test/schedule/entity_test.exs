defmodule Schedule.EntityTest do
  use ExUnit.Case

  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.Schedule.Builder, as: ScheduleBuilder
  alias Core.Group.Builder, as: GroupBuilder

  test "Построение сущности" do
    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234",
    })

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест"
    })

    {result, _} = ScheduleBuilder.build(%{
      timings: [%{
        playlist: playlist, 
        type: "Каждый день",
        day: nil, 
        start_hour: 1,
        end_hour: 2,
        start_minute: 0,
        end_minute: 30
      }], 
      group: group, 
      name: "Тест_1234"
    })

    assert result == :ok
  end

  test "Построение сущности - не валидные тайминги" do
    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест",
    })

    {result, _} = ScheduleBuilder.build(%{
      timings: [%{
        playlist: playlist, 
        type: "Каждый день",
        day: nil, 
        start_hour: 1,
        end_hour: 2,
        start_minute: 0,
        end_minute: 30
      },%{
        playlist: playlist, 
        type: "Каждый день",
        day: nil, 
        start_hour: 1,
        end_hour: 2,
        start_minute: 0,
        end_minute: 30
      }], 
      group: group, 
      name: "Тест_1234"
    })

    assert result == :error
  end
end