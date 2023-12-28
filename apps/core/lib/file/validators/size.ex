defmodule Core.File.Validators.Size do
  @moduledoc """
    Валидирует размер файла
  """

  alias FileSize

  @max_size FileSize.new(50, :mb)
  @min_size FileSize.new(0, :mb)

  @spec valid({atom(), FileSize.t()}) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid({:ok, size}) when is_struct(size) do
    with compared <- FileSize.compare(size, @max_size),
         true <- compared == :eq || compared == :lt,
         compared <- FileSize.compare(size, @min_size),
         true <- compared == :gt do
      {:ok, true}
    else
      false -> {:error, "Невалидный размер файла"}
    end
  end

  def valid(_) do
    {:error, "Невалидные данные для валидации размера файла"}
  end
end