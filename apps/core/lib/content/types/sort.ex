defmodule Core.Content.Types.Sort do

  @type t :: %Core.Content.Types.Sort{
    name: binary(),
    duration: binary(),
    created: binary()
  }

  defstruct name: nil, duration: nil, created: "ASC"
end
