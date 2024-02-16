defmodule Core.Assembly.Builders.Url do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @web_dav_url Application.compile_env(:core, :web_dav_url, "http://192.168.0.106:8100/upload")

  @spec build(Success.t() | Error.t()) :: Success.t() | Error.t()
  def build({:ok, entity}) do
    {:ok, Map.put(entity, :url, "#{@web_dav_url}/#{entity.id}/#{entity.created}.zip")}
  end

  def build({:error, message}) do
    {:error, message}
  end
end