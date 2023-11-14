defmodule Core.Playlist.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.Playlist.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Content.Builder, as: BuilderContent
  alias Core.Playlist.Validators.Name

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    name: name,
    contents: contents,
    web_dav_url: web_dav_url
  }) do
    entity()
      |> name(name)
      |> contents(contents, web_dav_url)
  end

  def build(_) do
    Error.new("Не валидные данные для построения файла")
  end

   # Функция построения базового плэйлиста
  defp entity do
    Success.new(%Entity{
      name: nil,
      id: UUID.uuid4(),
      created: Date.utc_today,
      updated: Date.utc_today
    })
  end

  # Функция построения названия
  defp name({ :ok, entity }, new_name) do
    case Name.valid(new_name) do
      {:ok, _} -> Success.new(Map.put(entity, :name, new_name))
      {:error, error} -> {:error, error}
    end
  end

  defp name({:error, message}, _) do
    Error.new(message)
  end

  # Функция построения контента
  defp contents({ :ok, entity }, cnts, web_dav_url) when is_list(cnts) and length(cnts) > 0 do
    with fun <- fn (content) -> BuilderContent.build(
          Map.put(content, :web_dav_url, web_dav_url)
         ) end,
         cnts <- Enum.map(cnts, fun),
         nil <- Enum.find(cnts, fn tuple -> elem(tuple, 0) == :error end),
         cnts <- Enum.map(cnts, fn tuple -> elem(tuple, 1) end) do
      Success.new(Map.put(entity, :contents, cnts))
    else
      {:error, message} -> {:error, message}
    end
    
  end

  defp contents({ :ok, _ }, contents, _) when is_list(contents) and length(contents) == 0 do
    Error.new("Пустой список контента")
  end

  defp contents({:ok, _}, _, _) do
    Error.new("Не валидные данные для построения плэйлиста")
  end

  defp contents({:error, message}, _, _) do
    Error.new(message)
  end
end
