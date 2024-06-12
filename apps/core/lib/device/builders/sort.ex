defmodule Core.Device.Builders.Sort do

  alias Core.Shared.Validators.Sort

  alias Core.Shared.Builders.BuilderProperties

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, String.upcase(value)) 
    end

    sort()
      |> ip(Map.get(args, :ip), setter)
      |> latitude(Map.get(args, :latitude), setter)
      |> longitude(Map.get(args, :longitude), setter)
      |> is_active(Map.get(args, :is_active), setter)
      |> created(Map.get(args, :created), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для сортировки"}
  end

  defp sort do
    {:ok, %Core.Device.Types.Sort{}}
  end

  defp ip({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :ip, order)
    end
  end

  defp ip({:error, message}, _, _) do
    {:error, message}
  end

  defp latitude({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :latitude, order)
    end
  end

  defp latitude({:error, message}, _, _) do
    {:error, message}
  end

  defp longitude({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :longitude, order)
    end
  end

  defp longitude({:error, message}, _, _) do
    {:error, message}
  end

  defp is_active({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :is_active, order)
    end
  end

  defp is_active({:error, message}, _, _) do
    {:error, message}
  end

  defp created({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :created, order)
    end
  end

  defp created({:error, message}, _, _) do
    {:error, message}
  end
end