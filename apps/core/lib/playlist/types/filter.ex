defmodule Core.Playlist.Types.Filter do
  @moduledoc """

  """

  alias Core.Playlist.Types.Filter

  @type t :: %Filter{
    user_id:   binary(),
    name:      binary() | none(),
    created_f: binary() | none(),
    created_t: binary() | none()
  }

  defstruct user_id: nil, 
            name: nil, 
            created_f: nil,
            created_t: nil
end
