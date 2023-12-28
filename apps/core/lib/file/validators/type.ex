defmodule Core.File.Validators.Type do
  @moduledoc """
    Валидирует тип файла(для фильтра)
  """

  @types %{
    "Изображение": true,
    "Видеозапись": true
  }

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(type) when is_binary(type) do
    case Map.get(@types, type) do
      nil -> {:error, "Невалидный тип"}
      _ -> {:ok, true}
    end
  end

  def valid(_) do
    {:error, "Невалидный тип"}
  end
end