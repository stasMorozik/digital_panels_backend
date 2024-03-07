defmodule Core.Task.Types.Sort do

  @type t :: %Core.Task.Types.Sort{
    name: binary(),
    type: binary(),
    created: binary()
  }

  defstruct name: nil, type: nil, created: nil
end
