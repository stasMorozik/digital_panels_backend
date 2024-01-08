defmodule Core.Schedule.Entity do
  @moduledoc """
    Сущность - расписание
  """

  alias Core.Schedule.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    playlist: Core.Playlist.Entity.t(),
    once: boolean(),
    week_day: binary(),
    day: binary(),
    date: binary(),
    start: integer(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            name: nil, 
            playlist: nil,
            once: nil,
            week_day: nil,
            day: nil,
            date: nil,
            start: nil,
            created: nil,
            updated: nil
end