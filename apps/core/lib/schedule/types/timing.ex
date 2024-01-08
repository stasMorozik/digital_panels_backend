defmodule Core.Schedule.Types.Timing do
  @moduledoc """
    Тип - тайминг
  """

  alias Core.Schedule.Types.Timing

  @type t :: %Timing{
    id: binary(),
    playlist: Core.Playlist.Entity.t(),
    type: binary(),
    loop: boolean(),
    day: binary(),
    week_day: binary(),
    date: binary() | none(),
    start: integer()
  }

  defstruct id: nil,
            playlist: nil,
            type: nil,
            loop: nil,
            day: nil,
            week_day: nil,
            date: nil,
            start: nil
end