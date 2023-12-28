defmodule Core.File.Validators.Size do
  @moduledoc """
    Валидирует размер файла
  """

  alias FileSize

  @size FileSize.new(50, :mb)

  @spec valid(FileSize.t()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(size) when is_struct(size) do
    case FileSize.compare(size, @size) do
      :eq -> {:ok, true}
      :lt -> {:ok, true}
      :gt -> {:error, "Невалидный размер файла"}
    end
  end

  def valid(_) do
    {:error, "Невалидный размер файла"}
  end
end