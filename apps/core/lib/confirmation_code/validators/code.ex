defmodule Core.ConfirmationCode.Validators.Code do
  @moduledoc """
    Валидирует код
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(integer()) :: Success.t() | Error.t()
  def valid(code) when is_integer(code) do
    with true <- code >= 1000,
         true <- code <= 9999 do
      Success.new(true)
    else
      false -> Error.new("Не валидный код")
    end
  end

  def valid(_) do
    Error.new("Не валидный код")
  end
end
