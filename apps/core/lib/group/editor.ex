defmodule Core.Group.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Group.Entity

  alias Core.Shared.Builders.BuilderProperties
  alias Core.Group.Validators.Name
  alias Core.Group.Validators.Sum

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity(entity)
      |> name(Map.get(args, :name), setter)
      |> sum(Map.get(args, :sum), setter)
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования группы"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Entity{
      id: entity.id,
      name: entity.name,
      devices: entity.devices,
      sum: entity.sum,
      created: entity.created, 
      updated: Date.utc_today
    }}
  end

  defp name({:ok, entity}, name, setter) do
    case name do
      nil -> {:ok, entity}
      name -> BuilderProperties.build({:ok, entity}, Name, setter, :name, name)
    end
  end

  defp name({:error, message}, _, _) do
    {:error, message}
  end

  defp sum({:ok, entity}, sum, setter) do
    case sum do
      nil -> {:ok, entity}
      sum -> BuilderProperties.build({:ok, entity}, Sum, setter, :sum, sum)
    end
  end

  defp sum({:error, message}, _, _) do
    {:error, message}
  end
end