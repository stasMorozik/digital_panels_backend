defmodule Core.Content.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Content.Entity

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    entity(entity)
      |> name(Map.get(args, :name))
      |> duration(Map.get(args, :duration))
      |> file(Map.get(args, :file))
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования контента"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Entity{
      id: entity.id,
      name: entity.name,
      duration: entity.duration,
      file: entity.file,
      created: entity.created, 
      updated: Date.utc_today
    }}
  end

  defp name({:ok, entity}, name) do
    case name do
      nil -> {:ok, entity}
      name -> Core.Content.Builders.Name.build({:ok, entity}, name)
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end

  defp duration({:ok, entity}, duration) do
    case duration do
      nil -> {:ok, entity}
      duration -> Core.Content.Builders.Duration.build({:ok, entity}, duration)
    end
  end

  defp duration({:error, message}, _) do
    {:error, message}
  end

  defp file({:ok, entity}, file) do
    case file do
      nil -> {:ok, entity}
      file -> Core.Content.Builders.File.build({:ok, entity}, file)
    end
  end

  defp file({:error, message}, _) do
    {:error, message}
  end
end