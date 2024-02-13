defmodule Content.EntityTest do
  use ExUnit.Case

  alias Core.Content.Builder, as: ContentBuilder

  alias Core.File.Builder, as: FileBuilder

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

    {result, _} = ContentBuilder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: file
    })

    assert result == :ok
  end

  test "Построение сущности - невалидное название" do
    {:ok, file} = FileBuilder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {result, _} = ContentBuilder.build(%{
      name: "Тест_1234@",
      duration: 15,
      file: file
    })

    assert result == :error
  end

  test "Построение сущности - невалидная продолжительность" do
    {:ok, file} = FileBuilder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {result, _} = ContentBuilder.build(%{
      name: "Тест_1234",
      duration: 150,
      file: file
    })

    assert result == :error
  end

  test "Построение сущности - невалидный файл" do
    {result, _} = ContentBuilder.build(%{
      name: "Тест_1234",
      duration: 15,
      file: %{}
    })

    assert result == :error
  end
end