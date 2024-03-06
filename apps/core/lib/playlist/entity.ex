defmodule Core.Playlist.Entity do
  @moduledoc """
    Сущность - плэйлист
  """

  alias Core.Playlist.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    sum: integer(),
    contents: list(Core.Playlist.Types.Content.t()),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            name: nil,
            sum: nil,
            contents: nil,
            created: nil,
            updated: nil
end