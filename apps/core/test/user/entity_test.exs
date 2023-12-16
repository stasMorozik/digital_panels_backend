defmodule User.EntityTest do
  use ExUnit.Case

  alias Core.User.Builder
  alias Core.User.Editor

  test "Построение сущности" do
    {result, _} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    assert result == :ok
  end

  test "Построение сущности - не валидное имя" do
    {result, _} = Builder.build(%{
      name: "Иван1",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    assert result == :error
  end

  test "Построение сущности - не валидная фамилия" do
    {result, _} = Builder.build(%{
      name: "Иван",
      surname: "Иванович1",
      email: "test@gmail.com"
    })

    assert result == :error
  end

  test "Построение сущности - не валидное имя и фамилия" do
    {result, _} = Builder.build(%{
      name: "Иван1",
      surname: "Иванович1",
      email: "test@gmail.com"
    })

    assert result == :error
  end

  test "Построение сущности - не валидный адрес электронной почты" do
    {result, _} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail."
    })

    assert result == :error
  end

  test "Редактирование сущности" do
    {_, entity} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    {result, entity} = Editor.edit(entity, %{
      name: "Олег", 
      surname: "Васильевич", 
      email: "test1@gmail.com"
    })

    assert result == :ok
    assert entity.name == "Олег"
    assert entity.surname == "Васильевич"
    assert entity.email == "test1@gmail.com"
  end

  test "Редактирование сущности - только имя" do
    {_, entity} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    {result, entity} = Editor.edit(entity, %{
      name: "Олег"
    })

    assert result == :ok
    assert entity.name == "Олег"
    assert entity.surname == "Иванович"
    assert entity.email == "test@gmail.com"
  end

  test "Редактирование сущности - только фамилия" do
    {_, entity} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    {result, entity} = Editor.edit(entity, %{
      surname: "Васильевич"
    })

    assert result == :ok
    assert entity.name == "Иван"
    assert entity.surname == "Васильевич"
    assert entity.email == "test@gmail.com"
  end

  test "Редактирование сущности - только адрес электронной почты" do
    {_, entity} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    {result, entity} = Editor.edit(entity, %{
      email: "test1@gmail.com"
    })

    assert result == :ok
    assert entity.name == "Иван"
    assert entity.surname == "Иванович"
    assert entity.email == "test1@gmail.com"
  end

  test "Редактирование сущности - не валидное имя" do
    {_, entity} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    {result, _} = Editor.edit(entity, %{
      name: "Олег1", 
    })

    assert result == :error
  end

  test "Редактирование сущности - не валидная фамилия" do
    {_, entity} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    {result, _} = Editor.edit(entity, %{
      surname: "Иванович1", 
    })

    assert result == :error
  end

  test "Редактирование сущности - не валидный адрес элкетронной почты" do
    {_, entity} = Builder.build(%{
      name: "Иван",
      surname: "Иванович",
      email: "test@gmail.com"
    })

    {result, _} = Editor.edit(entity, %{
      email: "test@gmail.", 
    })

    assert result == :error
  end
end