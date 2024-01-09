defmodule Core.Schedule.Builders.Timing do
  
  alias UUID
  alias Core.Schedule.Types.Timing
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build(%{
    playlist: playlist, 
    type: type, 
    loop: loop, 
    day: day, 
    week_day: week_day, 
    date: date, 
    start: start
  }) do
    type() 
      |> Core.Schedule.Builders.Playlist.build(playlist)
      |> Core.Schedule.Builders.Type.build(type)
      |> Core.Schedule.Builders.Loop.build(loop)
      |> Core.Schedule.Builders.Day.build(day)
      |> Core.Schedule.Builders.WeekDay.build(week_day)
      |> Core.Schedule.Builders.Date.build(date)
      |> Core.Schedule.Builders.Start.build(start)
  end

  defp type do
    {:ok, %Timing{
      id: UUID.uuid4()
    }}
  end
end