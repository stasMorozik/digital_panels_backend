defmodule Core.Shared.Validators.Sort do
  @moduledoc """
    Валидирует параметры сортировки
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(order) when is_binary(order) do
    case String.upcase(order) do
      "ASC" -> Success.new(true)
      "DESC" -> Success.new(true)
      _ -> Error.new("Не валидный параметр сортировки")
    end
  end

  def valid(_) do
    Error.new("Не валидный параметр сортировки")
  end
end
