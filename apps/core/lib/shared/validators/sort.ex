defmodule Core.Shared.Validators.Sort do
  @moduledoc """
    Валидирует параметры сортировки
  """

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(order) when is_binary(order) do
    case String.upcase(order) do
      "ASC" -> {:ok, true}
      "DESC" -> {:ok, true}
      _ -> {:error, "Не валидный параметр сортировки"}
    end
  end

  def valid(_) do
    {:error, "Не валидный параметр сортировки"}
  end
end
