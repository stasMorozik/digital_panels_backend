defmodule File.BuildEntityTest do
  use ExUnit.Case

  alias Core.File.Builder

  doctest Core.File.Builder
  
  setup_all do
    File.touch("/tmp/not_emty.png", 1544519753)
    File.touch("/tmp/empty.png", 1544519753)
    
    File.write("/tmp/not_emty.png", "content")
    
    :ok
  end

  test "Build file 1" do
    {result, _} =
      Builder.build(%{
        path: "/tmp/not_emty.png",
        web_dav_url: "http://localhost"
      })

    assert result == :ok
  end

  test "Emtpy file" do
    {result, _} =
      Builder.build(%{
        path: "/tmp/emtpy.png",
        web_dav_url: "http://localhost"
      })

    assert result == :error
  end
end
