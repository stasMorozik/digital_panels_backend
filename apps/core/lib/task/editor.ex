defmodule Core.Task.Editor do
   @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Task.Entity

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Task.Validators.Name
  alias Core.Task.Validators.Playlist
  alias Core.Task.Validators.Group
  alias Core.Task.Validators.Type
  alias Core.Task.Validators.TypeDay
  alias Core.Task.Validators.TimePoints
  alias Core.Task.Validators.Hour
  alias Core.Task.Validators.Minute
  alias Core.Task.Validators.Sum

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
    simple_setter = fn (entity, key, value) -> 
      Map.put(entity, key, value) 
    end

    type_day_setter = fn (entity, key, {_, day}) -> 
      Map.put(entity, key, day) 
    end

    time_points_setter = fn (entity, key, {hour, minute}) ->
      hour = case hour == 24 do
        true -> 0
        false -> hour
      end

      minutes = (hour * 60) + minute

      Map.put(entity, key, minutes)
    end

    sum_setter = fn (entity, key, { {start_hour, start_minute}, {end_hour, end_minute} }) ->
      start_hour = case start_hour == 24 do
        true -> 0
        false -> start_hour
      end

      sum_start = (start_hour * 60) + start_minute

      end_hour = case end_hour == 24 do
        true -> 0
        false -> end_hour
      end

      sum_end = (end_hour * 60) + end_minute

      Map.put(entity, key, sum_end - sum_start)
    end
    
    entity(entity)
      |> name(name, simple_setter)
      |> playlist(playlist, simple_setter)
      |> group(group, simple_setter)
      |> BuilderProperties.build(Type, simple_setter, :type, type)
      |> BuilderProperties.build(TypeDay, type_day_setter, :day, {type, day})
      |> BuilderProperties.build(Hour, simple_setter, :start_hour, start_hour)
      |> BuilderProperties.build(Hour, simple_setter, :end_hour, end_hour)
      |> BuilderProperties.build(Minute, simple_setter, :start_minute, start_minute)
      |> BuilderProperties.build(Minute, simple_setter, :end_minute, end_minute) 
      |> BuilderProperties.build(TimePoints, time_points_setter, :start, {start_hour, start_minute})
      |> BuilderProperties.build(TimePoints, time_points_setter, :end, {end_hour, end_minute})
      |> BuilderProperties.build(Sum, sum_setter, :sum, { {start_hour, start_minute}, {end_hour, end_minute} })
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования задания"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Entity{
      id: entity.id,
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

  defp name({:ok, entity}, name, setter) do
    case name do
      nil -> {:ok, entity}
      name -> BuilderProperties.build({:ok, entity}, Name, setter, :name, name)
    end
  end

  defp name({:error, message}, _, _) do
    {:error, message}
  end

  defp playlist({:ok, entity}, playlist, setter) do
    case playlist do
      nil -> {:ok, entity}
      playlist -> BuilderProperties.build({:ok, entity}, Playlist, setter, :playlist, playlist)
    end
  end

  defp playlist({:error, message}, _, _) do
    {:error, message}
  end

  defp group({:ok, entity}, group, setter) do
    case group do
      nil -> {:ok, entity}
      group -> BuilderProperties.build({:ok, entity}, Group, setter, :group, group)
    end
  end

  defp group({:error, message}, _, _) do
    {:error, message}
  end
end