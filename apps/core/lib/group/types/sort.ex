defmodule Core.Group.Types.Sort do

  @type t :: %Core.Group.Types.Sort{
    name: binary(),
    sum: binary(),
    created: binary()
  }

  defstruct name: nil, sum: nil, created: nil
end
