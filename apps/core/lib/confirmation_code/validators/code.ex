defmodule Core.ConfirmationCode.Validators.Code do
  @moduledoc """
    Валидирует код
  """

  @min 1000
  @max 9999

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(code) when is_integer(code) do
    with true <- code >= @min,
         true <- code <= @max do
      {:ok, true}
    else
      false -> {:error, "Не валидный код"}
    end
  end

  def valid(_) do
    {:error, "Не валидный код"}
  end
end
