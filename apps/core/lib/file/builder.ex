defmodule Core.File.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.File.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.File.Validators.Size

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

  defp size({:ok, entity}, path) when is_struct(entity) do
    case Size.valid(path) do
      {:ok, size} -> Success.new(Map.put(entity, :size, size))
      {:error, messgae} -> {:error, messgae}
    end
  end

  defp size({:error, message}, _) when is_binary(message) do
    Error.new(message)
  end

  defp url({:ok, entity}, path, web_dav_url) 
   when is_struct(entity) 
   and is_binary(web_dav_url) 
   and is_binary(path) do
    basename = Path.basename(path)
    url = "#{web_dav_url}/#{entity.id}/#{basename}" 

    Success.new(Map.put(entity, :url, url))
  end

  defp url({:ok, entity}, _, _) when is_struct(entity) do
    Error.new("Не валидный url")
  end

  defp url({:error, message}, _, _) when is_binary(message) do
    Error.new(message)
  end
end