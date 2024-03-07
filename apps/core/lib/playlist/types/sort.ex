defmodule Core.Playlist.Types.Sort do

  @type t :: %Core.Playlist.Types.Sort{
    name: binary(),
    created: binary()
  }

  defstruct name: nil, created: nil
end
