defmodule Core.Content.Types.Filter do

  @type t :: %Core.Content.Types.Filter{
    name: binary(),
    duration_f: integer(),
    duration_t: integer(),
    created_f: binary(),
    created_t: binary()
  }

  defstruct name: nil,
            duration_f: nil,
            duration_t: nil,
            created_f: nil,
            created_t: nil
end
