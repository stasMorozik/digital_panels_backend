defmodule Core.Group.Types.Filter do

  @type t :: %Core.Group.Types.Filter{
    name: binary(),
    sum_f: integer(),
    sum_t: integer(),
    created_f: binary(),
    created_t: binary(),
  }

  defstruct name: nil, 
            sum_f: nil, 
            sum_t: nil, 
            created_f: nil, 
            created_t: nil
end
