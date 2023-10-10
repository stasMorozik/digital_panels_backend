defmodule ConfirmationCode.BuildEntityTest do
  use ExUnit.Case

  alias Core.ConfirmationCode.Builder
  alias Core.Shared.Validators.Email

  doctest Core.ConfirmationCode.Builder

  test "Build confirmation code 1" do
    {result, _} =
      Builder.build("test@gmail.com", Email)

    assert result == :ok
  end

  test "Invalid email" do
    {result, _} = Builder.build("test@.", Email)

    assert result == :error
  end
end
