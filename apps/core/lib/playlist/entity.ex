defmodule Core.Playlist.Entity do
  @moduledoc """
    Сущность - плэйлист
  """

  alias Core.Playlist.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    contents: list(Core.Playlist.Types.Content.t()),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            name: nil,
            contents: nil,
            created: nil,
            updated: nil
end