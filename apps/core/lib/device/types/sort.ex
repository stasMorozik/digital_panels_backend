defmodule Core.Device.Types.Sort do

  @type t :: %Core.Device.Types.Sort{
    ip: binary(),
    latitude: binary(),
    longitude: binary(),
    created: binary()
  }

  defstruct ip: nil, latitude: nil, longitude: nil, created: nil
end
