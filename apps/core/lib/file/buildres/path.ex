defmodule Core.File.Builders.Path do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, path) when is_binary(path) do
    {:ok, Map.put(entity, :path, path)}
  end

  def build({:ok, _}, _) do
    {:error, "Невалидный путь к файлу"}
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end