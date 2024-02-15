defmodule Core.File.Validators.Type do
  @moduledoc """
    Валидирует тип файла(для фильтра)
  """

  @types [
    "Изображение",
    "Видеозапись"
  ]

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(type) when is_binary(type) do
    case type in @types do
      false -> {:error, "Невалидный тип файла"}
      true -> {:ok, true}
    end
  end

  def valid(_) do
    {:error, "Невалидный тип файла"}
  end
end