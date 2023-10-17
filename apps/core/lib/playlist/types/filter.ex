defmodule Core.Playlist.Types.Filter do
  @moduledoc """

  """

  alias Core.Playlist.Types.Filter

  @type t :: %Filter{
    name: binary()    | none(),
    created: binary() | none(),
    updated: binary() | none()
  }

  defstruct name: nil, created: nil, updated: nil
end
