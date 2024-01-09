defmodule Core.Device.Types.Filter do

  @type t :: %Core.Device.Types.Filter{
    ip: binary(),
    latitude: float(),
    longitude: float(),
    created_f: binary(),
    created_t: binary()
  }

  defstruct ip: nil,
            latitude: nil,
            longitude: nil,
            created_f: nil,
            created_t: nil
end
