defmodule Core.Task.Builder do
  
  alias UUID
  alias Core.Task.Entity
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

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

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
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

    entity()
      |> BuilderProperties.build(Name, simple_setter, :name, name)
      |> BuilderProperties.build(Playlist, simple_setter, :playlist, playlist)
      |> BuilderProperties.build(Group, simple_setter, :group, group)
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

  def build(_) do
    {:error, "Не валидные данные для создания задания"}
  end

  defp entity do
    {:ok, %Entity{
      id: UUID.uuid4(),
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end