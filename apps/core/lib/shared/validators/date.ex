defmodule Core.Shared.Validators.Date do
  @moduledoc """
    Валидирует дату
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(str_date) when is_binary(str_date) do
    case Date.from_iso8601(str_date) do
      {:error, _} -> Error.new("Не валидная дата")
      {:ok, date} -> Success.new(date)
    end
  end

  def valid(_) do
    Error.new("Не валидная дата")
  end
end