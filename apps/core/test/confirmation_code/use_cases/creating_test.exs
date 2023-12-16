defmodule ConfirmationCode.UseCases.CreatingTest do
  use ExUnit.Case

  alias Core.ConfirmationCode.UseCases.Creating, as: UseCase
  
  alias Shared.FakeAdapters.Notifier
  alias ConfirmationCode.FakeAdapters.Inserting

  setup_all do
    :mnesia.create_schema([node()])

    :ok = :mnesia.start()

    :mnesia.delete_table(:codes)

    {:atomic, :ok} = :mnesia.create_table(
      :codes,
      [attributes: [:email, :created, :code, :confirmed]]
    )

    :ok
  end

  test "Создание кода подтверждения" do
    {result, _}  = UseCase.create(Inserting, Notifier, %{needle: "test@gmail.com"})

    assert result == :ok
  end

  test "Создание кода подтверждения - не валидный адрес электронной почты" do
    {result, _}  = UseCase.create(Inserting, Notifier, %{needle: "test@gmail."})

    assert result == :error
  end
end