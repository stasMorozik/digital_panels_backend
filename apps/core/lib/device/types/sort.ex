defmodule Core.Device.Types.Sort do

  @type t :: %Core.Device.Types.Sort{
    ip: binary(),
    latitude: binary(),
    longitude: binary(),
    is_active: binary(),
    created: binary()
  }

  defstruct ip: nil, 
            latitude: nil, 
            longitude: nil, 
            is_active: nil, 
            created: nil
end
