defmodule User.BuildEntityTest do
  use ExUnit.Case

  alias Core.User.Builder

  doctest Core.User.Builder

  test "Build user 1" do
    {result, _} =
      Builder.build(%{email: "test@gmail.com", name: "Пётр", surname: "Павел"})

    assert result == :ok
  end

  test "Build user 2" do
    {result, _} =
      Builder.build(%{email: "test@gmail.com", name: "Никита", surname: "Зябликов"})

    assert result == :ok
  end

  test "Build user 3" do
    {result, _} =
      Builder.build(%{email: "test@gmail.com", name: "Владимиръ", surname: "Недочётов"})

    assert result == :ok
  end

  test "Build user 4" do
    {result, _} =
      Builder.build(%{email: "test@gmail.com", name: "Joe", surname: "Armstrong"})

    assert result == :ok
  end

  test "Invalid email address" do
    {result, _} =
      Builder.build(%{email: "test@.", name: "Пётр", surname: "Павел"})

    assert result == :error
  end

  test "Emty email address" do
    {result, _} =
      Builder.build(%{email: nil, name: "Пётр", surname: "Павел"})

    assert result == :error
  end

  test "Invalid name" do
    {result, _} =
      Builder.build(%{email: "test@gmail.com", name: "Joe1", surname: "Armstrong"})

    assert result == :error
  end

  test "Empty name" do
    {result, _} =
      Builder.build(%{email: "test@gmail.com", name: nil, surname: "Armstrong"})

    assert result == :error
  end

  test "Invalid surname" do
    {result, _} =
      Builder.build(%{email: "test@gmail.com", name: "Joe", surname: "Armstrong1"})

    assert result == :error
  end

  test "Empty surname" do
    {result, _} =
      Builder.build(%{email: "test@gmail.com", name: "Joe", surname: nil})

    assert result == :error
  end

  test "Invalid data" do
    {result, _} =
      Builder.build(%{})

    assert result == :error
  end

  test "Empty data" do
    {result, _} =
      Builder.build(nil)

    assert result == :error
  end
end
