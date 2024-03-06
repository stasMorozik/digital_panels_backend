defmodule File.EntityTest do
  use ExUnit.Case

  alias Core.File.Builder

  setup_all do
    File.touch("/tmp/not_emty_png.png", 1544519753)
    File.touch("/tmp/not_emty_txt.txt", 1544519753)
    File.touch("/tmp/empty_png.png", 1544519753)
    
    File.write("/tmp/not_emty_png.png", "content")
    File.write("/tmp/not_emty_txt.txt", "content")

    :ok
  end

  test "Построение сущности" do
    {result, _} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    assert result == :ok
  end

  test "Построение сущности - невалидное расширение" do
    {result, _} = Builder.build(%{
      path: "/tmp/not_emty_txt.txt",
      name: Path.basename("/tmp/not_emty_txt.txt"),
      extname: Path.extname("/tmp/not_emty_txt.txt"),
      size: FileSize.from_file("/tmp/not_emty_txt.txt", :mb)
    })

    assert result == :error
  end

  test "Построение сущности - пустой файл" do
    {result, _} = Builder.build(%{
      path: "/tmp/empty_png.png",
      name: Path.basename("/tmp/empty_png.png"),
      extname: Path.extname("/tmp/empty_png.png"),
      size: FileSize.from_file("/tmp/empty_png.png", :mb)
    })

    assert result == :error
  end

  test "Построение сущности - файл не существует" do
    {result, _} = Builder.build(%{
      path: "/tmp/not_exists.png",
      name: Path.basename("/tmp/not_exists.png"),
      extname: Path.extname("/tmp/not_exists.png"),
      size: FileSize.from_file("/tmp/not_exists.png", :mb)
    })

    assert result == :error
  end
end