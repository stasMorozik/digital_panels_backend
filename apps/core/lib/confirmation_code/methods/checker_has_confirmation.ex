defmodule Core.ConfirmationCode.Methods.CheckerHasConfirmation do
  @moduledoc """
    Проверяет подтвердили ли код
  """

  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec has(Entity.t()) :: Success.t() | Error.t()
  def has(%Entity{created: _, confirmed: confirmed, code: _, needle: _}) do
    if confirmed do
      Success.new(true)
    else
      Error.new("Код не подтвердили")
    end
  end

  def has(_) do
    Error.new("Не валидные данные для проверки")
  end
end
