defmodule Core.File.Builders.Type do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

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

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, extname) do
    case Core.File.Validators.Extension.valid(extname) do
      {:ok, _} -> {:ok, Map.put(entity, :type, Map.get(@extensions_types, String.to_atom(extname)))}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end