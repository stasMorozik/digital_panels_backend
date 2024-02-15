defmodule Core.Task.Builder do
  
  alias UUID
  alias Core.Task.Entity
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

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
    type()
      |> Core.Task.Builders.Name.build(name)
      |> Core.Task.Builders.Playlist.build(playlist)
      |> Core.Task.Builders.Group.build(group)
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

  defp type do
    {:ok, %Entity{
      id: UUID.uuid4(),
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end