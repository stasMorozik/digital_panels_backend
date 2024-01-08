defmodule Core.Schedule.Entity do
  @moduledoc """
    Сущность - расписание
  """

  alias Core.Schedule.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    playlist: Core.Playlist.Entity.t(),
    group: Core.Group.Entity.t(),
    once: boolean(),
    week_day: binary(),
    day: binary(),
    date: binary(),
    start: integer(),
    created: binary(),
    updated: binary()
  }
end