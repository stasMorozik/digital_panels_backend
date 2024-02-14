defmodule Core.Schedule.Types.Filter do

  @type t :: %Core.Schedule.Types.Filter{
    name: binary(),
    created_f: binary(),
    created_t: binary(),
  }

  defstruct name: nil,
            created_f: nil, 
            created_t: nil
end
