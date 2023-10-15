defmodule Core.Playlist.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.Playlist.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Content.Builder, as: BuilderContent

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    name: name,
    contents: contents,
    web_dav_url: web_dav_url
  }) do
    entity()
      |> contents(contents, web_dav_url)
  end

   # Функция построения базового плэйлиста
   defp entity do
    Success.new(%Entity{
      id: UUID.uuid4(),
      created: Date.utc_today,
      updated: Date.utc_today
    })
  end

  # Функция построения контента
  defp contents({ :ok, entity }, contents, web_dav_url) 
    when length(contents) > 0 and is_struct(entity) and is_binary(web_dav_url) do
    with cnts <- handle_contents(contents, web_dav_url),
         nil <- Enum.find(cnts, fn tuple -> elem(tuple, 0) == :error end) do
      Success.new(Map.put(entity, :contents, cnts))
    else
      {:error, message} -> {:error, message}
    end
  end

  defp contents({ :ok, entity }, contents, _) when length(contents) == 0 and is_struct(entity) do
    Error.new("Пустой список контента")
  end

  defp contents({:ok, _}, _, _) do
    Error.new("Не валидные данные для построения плэйлиста")
  end

  defp contents({:error, message}, _, _) when is_binary(message) do
    Error.new(message)
  end

  defp handle_contents(contents, web_dav_url) do
    Enum.map(
      contents, 
      fn content -> BuilderContent.build(Map.put(content, :web_dav_url, web_dav_url)) end
    )
  end
end
