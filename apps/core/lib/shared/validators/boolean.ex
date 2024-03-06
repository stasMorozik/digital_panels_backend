defmodule Core.Shared.Validators.Boolean do
  @moduledoc """
    Валидирует булево значение
  """

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(bool) when is_boolean(bool) do
    {:ok, true}
  end

  def valid(_) do
    {:error, "Невалидное булево значение"}
  end
end