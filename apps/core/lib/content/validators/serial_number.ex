defmodule Core.Content.Validators.SerialNumber do
  @moduledoc """
    Валидирует порядковый номер в плэлисте
  """

  @min 1
  @max 20

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(serial_number) when is_integer(serial_number) do
    with true <- serial_number >= @min,
         true <- serial_number <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидный порядковый номер в плэлисте"}
    end
  end

  def valid(_) do
    {:error, "Невалидный порядковый номер в плэлисте"}
  end
end