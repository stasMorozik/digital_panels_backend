defmodule Playlist.EntityTest do
  use ExUnit.Case

  alias Core.Content.Builder, as: ContentBuilder
  alias Core.File.Builder, as: FileBuilder
  alias Core.Playlist.Builder, as: PlaylistBuilder

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

    {result, _} = PlaylistBuilder.build(%{
      name: "Тест_1234", 
      contents: [content]
    })

    assert result == :ok
  end

  test "Построение сущности - невалидный список контента" do
    {result, _} = PlaylistBuilder.build(%{
      name: "Тест_1234", 
      contents: []
    })

    assert result == :error
  end

  test "Построение сущности - не валидное название" do
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

    {result, _} = PlaylistBuilder.build(%{
      name: "Тест_1234@", 
      contents: [content]
    })

    assert result == :error
  end
end