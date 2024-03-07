defmodule Core.File.Types.Sort do

  @type t :: %Core.File.Types.Sort{
    size: binary(),
    type: binary(),
    created: binary()
  }

  defstruct size: nil, type: nil, created: nil
end
