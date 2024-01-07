defmodule Core.Playlist.Types.Filter do

  @type t :: %Core.Playlist.Types.Filter{
    name: binary(),
    created_f: binary(),
    created_t: binary(),
  }

  defstruct name: nil, created_f: nil, created_t: nil
end
