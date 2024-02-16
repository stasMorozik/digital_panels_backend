defmodule Core.Assembly.Types.Filter do

  @type t :: %Core.Assembly.Types.Filter{
    url: binary(),
    type: binary(),
    created_f: binary(),
    created_t: binary(),
  }

  defstruct url: nil, type: nil, created_f: nil, created_t: nil
end
