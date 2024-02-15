defmodule Core.Task.Editor do
   @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Task.Entity

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, %{
    name: name,
    playlist: playlist,
    group: group, 
    type: type,
    day: day, 
    start_hour: start_hour,
    end_hour: end_hour,
    start_minute: start_minute,
    end_minute: end_minute
  }) do
    entity(entity)
      |> name(name)
      |> playlist(playlist)
      |> group(group)
      |> Core.Task.Builders.Type.build(type)
      |> Core.Task.Builders.Day.build(type, day)
      |> Core.Task.Builders.Hour.build({:start, start_hour})
      |> Core.Task.Builders.Hour.build({:end, end_hour})
      |> Core.Task.Builders.Minute.build({:start, start_minute})
      |> Core.Task.Builders.Minute.build({:end, end_minute})
      |> Core.Task.Builders.Start.build({start_hour, start_minute})
      |> Core.Task.Builders.End.build({end_hour, end_minute})
      |> Core.Task.Builders.Sum.build({start_hour, start_minute}, {end_hour, end_minute})
      |> Core.Task.Builders.Hash.build(type, day)
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования плэйлиста"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Entity{
      id: entity.id,
      hash: entity.hash,
      name: entity.name,
      playlist: entity.playlist,
      group: entity.group,
      type: entity.type,
      day: entity.day,
      start_hour: entity.start_hour,
      end_hour: entity.end_hour,
      start_minute: entity.start_minute,
      end_minute: entity.end_minute,
      start: entity.start,
      end: entity.end,
      sum: entity.sum,
      created: entity.created,
      updated: Date.utc_today
    }}
  end

  defp name({:ok, entity}, name) do
    case name do
      nil -> {:ok, entity}
      name -> Core.Task.Builders.Name.build({:ok, entity}, name)
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end

  defp playlist({:ok, entity}, playlist) do
    case playlist do
      nil -> {:ok, entity}
      playlist -> Core.Task.Builders.Playlist.build({:ok, entity}, playlist)
    end
  end

  defp playlist({:error, message}, _) do
    {:error, message}
  end

  defp group({:ok, entity}, group) do
    case group do
      nil -> {:ok, entity}
      group -> Core.Task.Builders.Group.build({:ok, entity}, group)
    end
  end

  defp group({:error, message}, _) do
    {:error, message}
  end
end