defmodule Core.Task.Entity do
  @moduledoc """
    Тип - тайминг
  """

  alias Core.Task.Entity

  @type t :: %Entity{
    id: binary(),
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

  defimpl Jason.Encoder, for: Core.Task.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [
        :id,
        :name,
        :playlist,
        :group,
        :type,
        :day,
        :start_hour,
        :end_hour,
        :start_minute,
        :end_minute,
        :start,
        :end,
        :sum,
        :created,
        :updated
      ]), opts)
    end
  end
end