defmodule ConfirmationCode.EntityTest do
  use ExUnit.Case

  alias Core.ConfirmationCode.Builder
  alias Core.ConfirmationCode.Methods.Confirming
  alias Core.Shared.Validators.Email

  test "Билд сущности" do
    {result, _} = Builder.build(Email, "test@gmail.com")

    assert result == :ok
  end
end