defmodule Core.File.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias FileSize

  alias Core.Shared.Builders.BuilderProperties
  
  alias Core.File.Validators.Extension
  alias Core.File.Validators.Size
  alias Core.File.Validators.Path

  @url_web_dav Application.compile_env(:core, :url_web_dav)

  @image "Изображение"
  @video "Видеозапись"

  @extensions_types %{
    ".jpg": @image,
    ".jpeg": @image,
    ".png": @image,
    ".gif": @image,
    ".mp4": @video,
    ".avi": @video
  }

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{path: path, name: name, extname: extname, size: size}) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    size_setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, FileSize.to_integer(elem(value, 1)))  
    end

    setter_type = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, Map.get(@extensions_types, String.to_atom(value)))  
    end

    setter_url = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, "#{@url_web_dav}/#{entity.id}/#{value}")  
    end

    entity()
      |> BuilderProperties.build(Extension, setter, :extension, extname)
      |> BuilderProperties.build(Size, size_setter, :size, size)
      |> BuilderProperties.build(Path, setter, :path, path)
      |> BuilderProperties.build(Extension, setter_type, :type, extname)
      |> BuilderProperties.build(Path, setter_url, :url, name)
  end

  def build(_) do
    {:error, "Невалидные данные для построения пользователя"}
  end

  defp entity do
    {:ok, %Core.File.Entity{
      id: UUID.uuid4(), 
      created: Date.utc_today
    }}
  end
end