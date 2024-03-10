defmodule Core.Assembly.Builders.Url do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @url_web_dav Application.compile_env(:core, :url_web_dav)

  @spec build(Success.t() | Error.t()) :: Success.t() | Error.t()
  def build({:ok, entity}) do
    {:ok, Map.put(entity, :url, "#{@url_web_dav}/#{entity.id}/#{entity.created}.zip")}
  end

  def build({:error, message}) do
    {:error, message}
  end
end