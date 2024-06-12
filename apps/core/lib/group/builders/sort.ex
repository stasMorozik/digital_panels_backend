defmodule Core.Group.Builders.Sort do
  
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
      |> name(Map.get(args, :name), setter)
      |> sum(Map.get(args, :sum), setter)
      |> created(Map.get(args, :created), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для сортировки"}
  end

  defp sort do
    {:ok, %Core.Group.Types.Sort{}}
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

  defp sum({:ok, sort}, order, setter) do
    case order do
      nil -> {:ok, sort}
      order -> BuilderProperties.build({:ok, sort}, Sort, setter, :sum, order)
    end
  end

  defp sum({:error, message}, _, _) do
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