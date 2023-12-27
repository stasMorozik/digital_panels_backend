defmodule ConfirmationCode.EntityTest do
  use ExUnit.Case

  alias Core.ConfirmationCode.Builder
  alias Core.ConfirmationCode.Methods.Confirmatory
  alias Core.Shared.Validators.Email

  test "Построение сущности" do
    {result, _} = Builder.build(Email, "test@gmail.com")

    assert result == :ok
  end

  test "Построение сущности - не валидный адрес электронной почты" do
    {result, _} = Builder.build(Email, "test@gmail.")

    assert result == :error
  end

  test "Подтверждение адреса электронной почты" do
    {_, entity} = Builder.build(Email, "test@gmail.com")

    {result, _} = Confirmatory.confirm(entity, entity.code)

    assert result == :ok
  end

  test "Подтверждение адреса электронной почты - не верный код" do
    {_, entity} = Builder.build(Email, "test@gmail.com")

    {result, _} = Confirmatory.confirm(entity, 12)

    assert result == :error
  end
end