defmodule Core.File.Validators.File do
  @moduledoc """
    Валидирует размер файла
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @extensions = %{
    ".jpg":  true
    ".jpeg": true,
    ".png":  true
    ".gif":  true,
    ".avif": true
  }

  @spec valid(integer()) :: Success.t() | Error.t()
  def valid(path) when is_binary(path) do
    with {:ok, file_stat} <- File.stat(path),
         size <- file_stat.size,
         true <- size > 0,
         extname <- Path.extname(path),
         true <- Map.get(@extensions, extname) do
      {:ok, file_stat}
    else
      nil -> Error.new("Не валидное расширение файла")
      false -> Error.new("Пустой файл")
      {:error, _} -> Error.new("Не удалось получить размер файла")
    end
  end

  def valid(_) do
    Error.new("Не удалось получить размер файла")
  end
end