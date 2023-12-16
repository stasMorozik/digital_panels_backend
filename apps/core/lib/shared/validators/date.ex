defmodule Core.Shared.Validators.Date do
  @moduledoc """
    Валидирует дату
  """

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(str_date) when is_binary(str_date) do
    case Date.from_iso8601(str_date) do
      {:error, _} -> {:error, "Не валидная дата"}
      {:ok, _} -> {:ok, true}
    end
  end

  def valid(_) do
    {:error, "Не валидная дата"}
  end
end