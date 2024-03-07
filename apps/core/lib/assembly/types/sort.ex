defmodule Core.Assembly.Types.Sort do

  @type t :: %Core.Assembly.Types.Sort{
    type: binary(),
    created: binary()
  }

  defstruct size: nil, type: nil, created: nil
end
