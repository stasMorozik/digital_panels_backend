defmodule Core.File.Validators.Extension do
  @moduledoc """
    Валидирует расширение файла
  """

  @extensions [
    ".jpg",
    ".jpeg",
    ".png",
    ".gif",
    ".mp4",
    ".avi"
  ]

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(extname) when is_binary(extname) do
    case extname in @extensions do
      false -> {:error, "Невалидное расширение файла"}
      true -> {:ok, true}
    end
  end

  def valid(_) do
    {:error, "Невалидное расширение файла"}
  end
end