defmodule Group.EntityTest do
  use ExUnit.Case

  alias Core.Group.Builder, as: GroupBuilder

  test "Построение сущности" do
    {result, _} = GroupBuilder.build(%{
      name: "Тест"
    })

    assert result == :ok
  end

  test "Построение сущности - невалидное название" do
    {result, _} = GroupBuilder.build(%{
      name: "Тест@",
    })

    assert result == :error
  end
end