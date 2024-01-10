defmodule Core.Schedule.Editor do
  
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Schedule.Entity

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    entity(entity)
      |> name(Map.get(args, :name))
      |> group(Map.get(args, :group))
      |> Core.Schedule.Builders.Timings.build(Map.get(args, :timings, []))
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования группы"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Entity{
      id: entity.id, 
      name: entity.name, 
      timings: entity.timings,
      group: entity.group,
      created: entity.created,
      updated: Date.utc_today
    }}
  end

  defp name({:ok, entity}, name) do
    case name do
      nil -> {:ok, entity}
      name -> Core.Schedule.Builders.Name.build({:ok, entity}, name)
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end

  defp group({:ok, entity}, group) do
    case group do
      nil -> {:ok, entity}
      group -> Core.Schedule.Builders.Group.build({:ok, entity}, group)
    end
  end

  defp group({:error, message}, _) do
    {:error, message}
  end
end