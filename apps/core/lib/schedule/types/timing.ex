defmodule Core.Schedule.Types.Timing do
  @moduledoc """
    Тип - тайминг
  """

  alias Core.Schedule.Types.Timing

  @type t :: %Timing{
    id: binary(),
    playlist: Core.Playlist.Entity.t(),
    type: binary(),
    day: integer(),
    start_hour: integer(),
    end_hour: integer(),
    start_minute: integer(),
    end_minute: integer(),
    start: integer(),
    end: integer(),
    sum: integer()
  }

  defstruct id: nil,
            playlist: nil,
            type: nil,
            day: nil,
            start_hour: nil,
            end_hour: nil,
            start_minute: nil,
            end_minute: nil,
            start: nil,
            end: nil,
            sum: nil
end