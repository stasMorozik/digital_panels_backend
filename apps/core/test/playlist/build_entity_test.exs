defmodule Playlist.BuildEntityTest do
  use ExUnit.Case

  alias Core.Playlist.Builder

  doctest Core.Playlist.Builder
  
  setup_all do
    File.touch("/tmp/not_emty.txt", 1544519753)
    File.touch("/tmp/empty.txt", 1544519753)
    
    File.write("/tmp/not_emty.txt", "content")
    
    :ok
  end

  test "Build playlist" do
    {result, _} = Builder.build(%{
      name: "test",
      contents: [
        %{
          file: %{
            path: "/tmp/not_emty.txt"
          },
          display_duration: 15
        }
      ],
      web_dav_url: "http://localhost"
    })
    
    assert result == :ok
  end

  test "Empty file" do
    {result, _} =
      Builder.build(%{
        name: "test",
        contents: [
          %{
            file: %{
              path: "/tmp/empty.txt"
            },
            display_duration: 15
          }
        ],
        web_dav_url: "http://localhost"
      })
    
    assert result == :error
  end

  test "Empty contents" do
    {result, _} = Builder.build(%{
      name: "test",
      contents: [
        
      ],
      web_dav_url: "http://localhost"
    })
    
    assert result == :error
  end

  test "Empty web dav url" do
    {result, _} = Builder.build(%{
      name: "test",
      contents: [
        %{
          file: %{
            path: "/tmp/not_emty.txt"
          },
          display_duration: 15
        }
      ],
    })
    
    assert result == :error
  end
end