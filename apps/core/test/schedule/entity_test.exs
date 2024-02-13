defmodule Schedule.EntityTest do
  use ExUnit.Case

  alias Core.Content.Builder, as: ContentBuilder
  alias Core.File.Builder, as: FileBuilder
  alias Core.Playlist.Builder, as: PlaylistBuilder
  alias Core.Schedule.Builder, as: ScheduleBuilder
  alias Core.Group.Builder, as: GroupBuilder
  alias Core.Device.Builder, as: DeviceBuilder

  setup_all do
    File.touch("/tmp/not_emty_png.png", 1544519753)
    File.write("/tmp/not_emty_png.png", "content")

    :ok
  end

  test "Построение сущности" do
    {:ok, file} = FileBuilder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {:ok, content} = ContentBuilder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file
    })

    {:ok, playlist} = PlaylistBuilder.build(%{
      name: "Тест_1234", 
      contents: [content]
    })

    {:ok, device} = DeviceBuilder.build(%{
      ip: "192.168.1.98",
      latitude: 78.454567,
      longitude: 98.3454,
      desc: "Описание"
    })

    {:ok, group} = GroupBuilder.build(%{
      name: "Тест",
      devices: [device]
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
end