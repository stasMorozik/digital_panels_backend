defmodule Core.Content.Builders.Filter do
  
  alias Core.Content.Validators.Name
  alias Core.Content.Validators.Duration
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
      |> duration_f(Map.get(args, :duration_f), setter)
      |> duration_t(Map.get(args, :duration_t), setter)
      |> created_f(Map.get(args, :created_f), setter)
      |> created_t(Map.get(args, :created_t), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Core.Content.Types.Filter{}}
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

  defp duration_f({:ok, filter}, duration_f, setter) do
    case duration_f do
      nil -> {:ok, filter}
      duration_f -> BuilderProperties.build({:ok, filter}, Duration, setter, :duration_f, duration_f)
    end
  end

  defp duration_f({:error, message}, _, _) do
    {:error, message}
  end

  defp duration_t({:ok, filter}, duration_t, setter) do
    case duration_t do
      nil -> {:ok, filter}
      duration_t -> BuilderProperties.build({:ok, filter}, Duration, setter, :duration_t, duration_t)
    end
  end

  defp duration_t({:error, message}, _, _) do
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