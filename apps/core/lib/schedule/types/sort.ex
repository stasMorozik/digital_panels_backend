defmodule Core.Schedule.Types.Sort do

  @type t :: %Core.Schedule.Types.Sort{
    name: binary(),
    created: binary()
  }

  defstruct name: nil, created: "ASC"
end
