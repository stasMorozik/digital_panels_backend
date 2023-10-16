defmodule Core.File.Validators.Size do
  @moduledoc """
    Валидирует размер файла
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(integer()) :: Success.t() | Error.t()
  def valid(path) when is_binary(path) do
    with {:ok, file_stat} <- File.stat(path),
         size <- file_stat.size,
         true <- size > 0 do
      {:ok, file_stat.size}
    else
      {:error, _} -> Error.new("Не удалось получить размер файла")
      false -> Error.new("Пустой файл")
    end
  end

  def valid(_) do
    Error.new("Не удалось получить размер файла")
  end
end