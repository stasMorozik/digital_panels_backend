defmodule Core.Schedule.Builders.Timing do
  
  alias UUID
  alias Core.Schedule.Types.Timing
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    playlist: playlist, 
    type: type,
    day: day, 
    start_hour: start_hour,
    end_hour: end_hour,
    start_minute: start_minute,
    end_minute: end_minute
  }) do
    type() 
      |> Core.Schedule.Builders.Playlist.build(playlist)
      |> Core.Schedule.Builders.Type.build(type)
      |> Core.Schedule.Builders.Day.build(type, day)
      |> Core.Schedule.Builders.Hour.build(:start, start_hour)
      |> Core.Schedule.Builders.Hour.build(:end, end_hour)
      |> Core.Schedule.Builders.Minute.build(:start, start_minute)
      |> Core.Schedule.Builders.Minute.build(:end, end_minute)
      |> Core.Schedule.Builders.Start.build({start_hour, start_minute})
      |> Core.Schedule.Builders.End.build({end_hour, end_minute})
      |> Core.Schedule.Builders.Sum.build({start_hour, start_minute}, {end_hour, end_minute})
  end

  defp type do
    {:ok, %Timing{
      id: UUID.uuid4()
    }}
  end
end