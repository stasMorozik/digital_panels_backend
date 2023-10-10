defmodule ConfirmationCode.VerifierTest do
  use ExUnit.Case

  alias Core.Shared.Validators.Email
  alias Core.ConfirmationCode.Builder
  alias Core.ConfirmationCode.Methods.Verifier

  doctest Core.ConfirmationCode.Builder
  doctest Core.ConfirmationCode.Methods.Verifier

  test "Verifier code" do
    {_, entity} = Builder.build("test@gmail.com", Email)

    {result, _} = Verifier.verify(entity, entity.code)

    assert result == :ok
  end

  test "Invalid code" do
    {_, entity} = Builder.build("test@gmail.com", Email)

    {result, _} = Verifier.verify(entity, 12)

    assert result == :error

    {result, _} = Verifier.verify(entity, nil)

    assert result == :error
  end

  test "Wrong time" do
    {_, entity} = Builder.build("test@gmail.com", Email)

    {:ok, utc_date} = DateTime.now("Etc/UTC")

    entity = Map.put(entity, :created, DateTime.to_unix(utc_date) - 84000)

    {result, _} = Verifier.verify(entity, entity.code)

    assert result == :error
  end

  test "Wrong code" do
    {_, entity} = Builder.build("test@gmail.com", Email)

    {result, _} = Verifier.verify(entity, 1234)

    assert result == :error
  end
end
