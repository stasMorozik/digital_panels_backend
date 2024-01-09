defmodule Core.Group.Validators.Sum do
  @moduledoc """
    Валидирует количество устройств
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @min 1
  @max 100

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(sum) when is_integer(sum) do
    with true <- sum >= @min,
         true <- sum <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидное количество устройств"}
    end
  end

  def valid(_) do
    {:error, "Невалидное количество устройств"}
  end
end