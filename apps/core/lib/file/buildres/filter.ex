defmodule Core.File.Builders.Filter do
  
  alias Core.File.Validators.Extension
  alias Core.File.Validators.Size
  alias Core.File.Validators.Type
  alias Core.Shared.Validators.Date

  alias Core.Shared.Builders.BuilderProperties

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    filter()
      |> type(Map.get(args, :type), setter)
      |> url(Map.get(args, :url), setter)
      |> extension(Map.get(args, :extension), setter)
      |> size(Map.get(args, :size), setter)
      |> created_f(Map.get(args, :created_f), setter)
      |> created_t(Map.get(args, :created_t), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.File.Types.Filter{}}
  end

  defp type({:ok, filter}, type, setter) do
    case type do
      nil -> {:ok, filter}
      type -> BuilderProperties.build({:ok, filter}, Type, setter, :type, type)
    end
  end

  defp type({:error, message}, _, _) do
    {:error, message}
  end

  defp url({:ok, filter}, url, setter) do
    case url do
      nil -> {:ok, filter}
      url -> BuilderProperties.build({:ok, filter}, Path, setter, :url, url)
    end
  end

  defp url({:error, message}, _, _) do
    {:error, message}
  end

  defp extension({:ok, filter}, ext, setter) do
    case ext do
      nil -> {:ok, filter}
      ext -> BuilderProperties.build({:ok, filter}, Extension, setter, :extension, ext)
    end
  end

  defp extension({:error, message}, _, _) do
    {:error, message}
  end

  defp size({:ok, filter}, size, setter) do
    case size do
      nil -> {:ok, filter}
      size -> BuilderProperties.build({:ok, filter}, Size, setter, :size, size)
    end
  end

  defp size({:error, message}, _, _) do
    {:error, message}
  end

  defp created_f({:ok, filter}, created_f, setter) do
    case created_f do
      nil -> {:ok, filter}
      created_f -> BuilderProperties.build({:ok, filter}, Date, setter, :created_f, created_f)
    end
  end

  defp created_f({:error, message}, _, _) do
    {:error, message}
  end

  defp created_t({:ok, filter}, created_t, setter) do
    case created_t do
      nil -> {:ok, filter}
      created_t -> BuilderProperties.build({:ok, filter}, Date, setter, :created_t, created_t)
    end
  end

  defp created_t({:error, message}, _, _) do
    {:error, message}
  end
end