defmodule Content.BuildEntityTest do
  use ExUnit.Case

  alias Core.Content.Builder

  doctest Core.Content.Builder
  
  setup_all do
    File.touch("/tmp/not_emty.txt", 1544519753)
    File.touch("/tmp/empty.txt", 1544519753)
    
    File.write("/tmp/not_emty.txt", "content")
    
    :ok
  end

  test "Build content 1" do
    {result, _} =
      Builder.build(%{
        file: %{
          path: "/tmp/not_emty.txt",
          web_dav_url: "http://localhost"
        },
        display_duration: 15
      })

    assert result == :ok
  end

  test "Emtpy file" do
    {result, _} =
      Builder.build(%{
        file: %{
          path: "/tmp/emty.txt",
          web_dav_url: "http://localhost"
        },
        display_duration: 15
      })

    assert result == :error
  end

  test "Ivalid duration" do
    {result, _} =
      Builder.build(%{
        file: %{
          path: "/tmp/not_emty.txt",
          web_dav_url: "http://localhost"
        },
        display_duration: 0
      })

    assert result == :error
  end
end
