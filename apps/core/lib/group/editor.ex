defmodule Core.Group.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Group.Entity

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    entity(entity)
      |> name(Map.get(args, :name))
      |> Core.Group.Builders.Devices.build(Map.get(args, :devices, []))
      |> Core.Group.Builders.Sum.build(Map.get(args, :devices, []))
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

  defp name({:ok, entity}, name) do
    case name do
      nil -> {:ok, entity}
      name -> Core.Group.Builders.Name.build({:ok, entity}, name)
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end
end