defmodule Core.Content.Types.Filter do

  @type t :: %Core.Content.Types.Filter{
    identifiers: list(),
    name: binary(),
    duration: integer(),
    created_f: binary(),
    created_t: binary()
  }

  defstruct identifiers: nil, name: nil, duration: nil, created_f: nil, created_t: nil
end
