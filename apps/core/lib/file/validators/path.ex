defmodule Core.File.Validators.Path do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(path) when is_binary(path) do
    {:ok, true}
  end

  def valid(_) do
    {:error, "Невалидный путь к файлу"}
  end
end