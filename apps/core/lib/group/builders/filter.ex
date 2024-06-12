defmodule Core.Group.Builders.Filter do
  
  alias Core.Group.Validators.Name
  alias Core.Group.Validators.Sum
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
      |> name(Map.get(args, :name), setter)
      |> sum_f(Map.get(args, :sum_f), setter)
      |> sum_t(Map.get(args, :sum_t), setter)
      |> created_f(Map.get(args, :created_f), setter)
      |> created_t(Map.get(args, :created_t), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.Group.Types.Filter{}}
  end

  defp name({:ok, filter}, name, setter) do
    case name do
      nil -> {:ok, filter}
      name -> BuilderProperties.build({:ok, filter}, Name, setter, :name, name)
    end
  end

  defp name({:error, message}, _, _) do
    {:error, message}
  end

  defp sum_f({:ok, filter}, sum_f, setter) do
    case sum_f do
      nil -> {:ok, filter}
      sum_f -> BuilderProperties.build({:ok, filter}, Sum, setter, :sum_f, sum_f)
    end
  end

  defp sum_f({:error, message}, _, _) do
    {:error, message}
  end

  defp sum_t({:ok, filter}, sum_t, setter) do
    case sum_t do
      nil -> {:ok, filter}
      sum_t -> BuilderProperties.build({:ok, filter}, Sum, setter, :sum_t, sum_t)
    end
  end

  defp sum_t({:error, message}, _, _) do
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