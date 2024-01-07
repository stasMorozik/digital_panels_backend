defmodule Core.Playlist.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Playlist.Entity

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    entity(entity)
      |> name(Map.get(args, :name))
      |> Core.Playlist.Builders.Contents.build(Map.get(args, :contents, []))
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования плэйлиста"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Entity{
      id: entity.id, 
      created: entity.created, 
      updated: Date.utc_today
    }}
  end

  defp name({:ok, entity}, name) do
    case name do
      nil -> {:ok, entity}
      name -> Core.Playlist.Builders.Name.build({:ok, entity}, name)
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end
end