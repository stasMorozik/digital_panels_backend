defmodule Playlist.EntityTest do
  use ExUnit.Case

  alias Core.Playlist.Builder, as: PlaylistBuilder


  test "Построение сущности" do
    {result, _} = PlaylistBuilder.build(%{
      name: "Тест_1234"
    })

    assert result == :ok
  end

  test "Построение сущности - не валидное название" do

    {result, _} = PlaylistBuilder.build(%{
      name: "Тест_1234@"
    })

    assert result == :error
  end
end