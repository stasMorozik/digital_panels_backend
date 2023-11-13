defmodule Core.File.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.File.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.File.Validators.File

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    path: path,
    web_dav_url: web_dav_url
  }) do
    entity(path)
      |> size(path)
      |> url(path, web_dav_url)
  end

  def build(_) do
    Error.new("Не валидные данные для построения файла")
  end

  # Функция построения базового файла
  defp entity(path) do
    Success.new(%Entity{
      id: UUID.uuid4(),
      path: path,
      created: Date.utc_today,
      updated: Date.utc_today
    })
  end

  defp file({:ok, entity}, path) do
    case File.valid(path) do
      {:ok, stat} -> Success.new(Map.put(entity, :size, stat.size))
      {:error, messgae} -> {:error, messgae}
    end
  end

  defp file({:error, message}, _) do
    Error.new(message)
  end

  defp url({:ok, entity}, path, web_dav_url) do
    basename = Path.basename(path)
    url = "#{web_dav_url}/#{entity.id}/#{basename}" 

    Success.new(Map.put(entity, :url, url))
  end

  defp url({:error, message}, _, _) do
    Error.new(message)
  end
end