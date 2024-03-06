defmodule Core.File.Builders.Url do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @url_web_dav Application.compile_env(:core, :url_web_dav)

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, name) when is_binary(name) do
    {:ok, Map.put(entity, :url, "#{@url_web_dav}/#{entity.id}/#{name}")}
  end

  def build({:ok, _}, _) do
    {:error, "Невалидный имя файла"}
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end