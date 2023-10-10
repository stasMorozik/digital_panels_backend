defmodule ConfirmationCode.UseCases.ConfirmingTest do
  use ExUnit.Case

  alias Core.ConfirmationCode.UseCases.Confirming, as: ConfirmingUseCase
  alias Core.ConfirmationCode.Builder
  alias Core.Shared.Validators.Email

  doctest Core.ConfirmationCode.UseCases.Confirming

  setup_all do

    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)

    {:atomic, :ok} = :mnesia.create_table(
      :codes,
      [attributes: [:needle, :created, :code, :confirmed]]
    )

    :ok
  end

  test "Confirm" do
    {_, confirmation_code} = Builder.build("ivan_sm@gmail.com", Email)

    args = %{needle: "ivan_sm@gmail.com", code: confirmation_code.code}

    {:ok, _} = FakeAdapters.ConfirmationCode.Inserting.transform(confirmation_code)

    {result, _} = ConfirmingUseCase.confirm(
      FakeAdapters.ConfirmationCode.Creating,
      FakeAdapters.ConfirmationCode.Getter,
      args
    )

    assert result == :ok
  end

  test "Invalid code" do
    {_, confirmation_code} = Builder.build("ivan_sm2@gmail.com", Email)

    args = %{needle: "ivan_sm2@gmail.com", code: 123}

    {:ok, _} = FakeAdapters.ConfirmationCode.Inserting.transform(confirmation_code)

    {result, _} = ConfirmingUseCase.confirm(
      FakeAdapters.ConfirmationCode.Creating,
      FakeAdapters.ConfirmationCode.Getter,
      args
    )

    assert result == :error
  end

  test "Not found code" do
    Builder.build("ivan_sm3@gmail.com", Email)

    args = %{needle: "ivan_sm3@gmail.com", code: 123}

    {result, _} = ConfirmingUseCase.confirm(
      FakeAdapters.ConfirmationCode.Creating,
      FakeAdapters.ConfirmationCode.Getter,
      args
    )

    assert result == :error
  end
end
