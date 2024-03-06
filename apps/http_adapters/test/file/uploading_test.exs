defmodule File.UploadingTest do
  use ExUnit.Case

  alias HttpAdapters.File.Uploading
  alias Core.File.Builder

  doctest HttpAdapters.File.Uploading

  setup_all do
    File.touch("/tmp/not_emty_png.png", 1544519753)
    File.write("/tmp/not_emty_png.png", "content")
  end

  test "Insert" do
    {:ok, user} = Core.User.Builder.build(%{
      email: "test@gmail.com",
      name: "Тест",
      surname: "Тестович",
    })

    {:ok, file} = Builder.build(%{
      path: "/tmp/not_emty_png.png",
      name: Path.basename("/tmp/not_emty_png.png"),
      extname: Path.extname("/tmp/not_emty_png.png"),
      size: FileSize.from_file("/tmp/not_emty_png.png", :mb)
    })

    {result, _} = Uploading.transform(file, user)

    assert result == :ok
  end
end