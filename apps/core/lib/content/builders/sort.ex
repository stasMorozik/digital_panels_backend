defmodule Core.Content.Builders.Sort do
  
  alias Core.Shared.Validators.Sort

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

    sort()
      |> name(Map.get(args, :name), setter)
      |> duration(Map.get(args, :duration), setter)
      |> created(Map.get(args, :created), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для сортировки"}
  end

  defp sort do
    {:ok, %Core.Content.Types.Sort{}}
  end

  defp name({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :name, order)
    end
  end

  defp name({:error, message}, _, _) do
    {:error, message}
  end

  defp duration({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :duration, order)
    end
  end

  defp duration({:error, message}, _, _) do
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