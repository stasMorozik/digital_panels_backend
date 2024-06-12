defmodule Core.File.Builders.Sort do
  
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
      |> size(Map.get(args, :size), setter)
      |> type(Map.get(args, :type), setter)
      |> created(Map.get(args, :created), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для сортировки"}
  end

  defp sort do
    {:ok, %Core.File.Types.Sort{}}
  end

  defp size({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :size, order)
    end
  end

  defp size({:error, message}, _, _) do
    {:error, message}
  end

  defp type({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :type, order)
    end
  end

  defp type({:error, message}, _, _) do
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