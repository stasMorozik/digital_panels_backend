defmodule Core.Assembly.Types.Filter do

  @type t :: %Core.Assembly.Types.Filter{
    url: binary(),
    type: binary(),
    group: binary(),
    status: boolean(),
    created_f: binary(),
    created_t: binary(),
  }

  defstruct url: nil, 
            type: nil,
            group: nil,
            status: nil,
            created_f: nil, 
            created_t: nil
end
