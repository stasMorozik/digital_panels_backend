defmodule Core.Playlist.Types.Filter do
  @moduledoc """

  """

  alias Core.Playlist.Types.Filter

  @type t :: %Filter{
    user_id: binary(),
    name: binary()    | none(),
    created: binary() | none(),
    updated: binary() | none()
  }

  defstruct user_id: nil, name: nil, created: nil, updated: nil
end
