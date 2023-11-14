defmodule Core.Shared.Validators.Boolean do
  @moduledoc """
    Валидирует дату
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(boolean()) :: Success.t() | Error.t()
  def valid(bool) when is_boolean(bool) do
    Success.new(bool)
  end

  def valid(_) do
    Error.new("Не валидное булево значение")
  end
end