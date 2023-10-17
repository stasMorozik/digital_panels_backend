defmodule Core.Playlist.Entity do
  @moduledoc """
    Сущность - плэйлист
  """

  alias Core.Playlist.Entity, as: PlaylistEntity
  alias Core.Content.Entity, as: ContentEntity

  @type t :: %PlaylistEntity{
    id: binary(),
    name: binary(),
    contents: list(ContentEntity.t()),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            name: nil,
            contents: [],
            created: nil,
            updated: nil
end
