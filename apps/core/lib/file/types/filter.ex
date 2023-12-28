defmodule Core.File.Types.Filter do

  @type t :: %Core.File.Types.Filter{
    type: binary(),
    extension: binary(),
    size: integer(),
    created_f: binary(),
    created_t: binary(),
  }

  defstruct type: nil, extension: nil, size: nil, created_f: nil, created_t: nil
end
