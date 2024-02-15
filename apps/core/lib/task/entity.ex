defmodule Core.Task.Entity do
  @moduledoc """
    Тип - тайминг
  """

  alias Core.Task.Entity

  @type t :: %Entity{
    id: binary(),
    hash: binary(),
    name: binary(),
    playlist: Core.Playlist.Entity.t(),
    group: Core.Group.Entity.t(),
    type: binary(),
    day: integer(),
    start_hour: integer(),
    end_hour: integer(),
    start_minute: integer(),
    end_minute: integer(),
    start: integer(),
    end: integer(),
    sum: integer(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            hash: nil,
            name: nil,
            playlist: nil,
            group: nil,
            type: nil,
            day: nil,
            start_hour: nil,
            end_hour: nil,
            start_minute: nil,
            end_minute: nil,
            start: nil,
            end: nil,
            sum: nil,
            created: nil,
            updated: nil
end