defmodule Core.Task.Types.Filter do

  @type t :: %Core.Task.Types.Filter{
    name: binary(),
    type: binary(),
    day: integer(),
    group: binary(),
    start: integer(),
    end: integer(),
    created_f: binary(),
    created_t: binary(),
  }

  defstruct name: nil,
            type: nil,
            day: nil,
            group: nil,
            start: nil,
            end: nil,
            created_f: nil, 
            created_t: nil
end
