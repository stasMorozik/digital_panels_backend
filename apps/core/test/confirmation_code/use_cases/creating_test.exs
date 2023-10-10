defmodule ConfirmationCode.UseCases.CreatingTest do
  use ExUnit.Case

  alias Core.ConfirmationCode.UseCases.Creating, as: CreatingUseCase

  alias FakeAdapters.Shared.Notifier
  alias FakeAdapters.ConfirmationCode.Creating

  doctest Core.ConfirmationCode.UseCases.Creating

  test "Create confirmation code 1" do
    {result, _} = CreatingUseCase.create(Creating, Notifier, "email@gmail.com")

    assert result == :ok
  end

  test "Invalid email" do
    {result, _} = CreatingUseCase.create(Creating, Notifier, "email@.")

    assert result == :error
  end

  test "Invalid adapters" do
    {result, _} = CreatingUseCase.create(:atom, :aother_atom, "email@.")

    assert result == :error
  end
end
