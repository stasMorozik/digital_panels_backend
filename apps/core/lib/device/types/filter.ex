defmodule Core.Device.Types.Filter do

  @type t :: %Core.Device.Types.Filter{
    ip: binary(),
    latitude_f: float(),
    latitude_t: float(),
    longitude_f: float(),
    longitude_t: float(),
    description: binary(),
    is_active: boolean(),
    created_f: binary(),
    created_t: binary()
  }

  defstruct ip: nil,
            latitude_f: nil,
            latitude_t: nil,
            longitude_f: nil,
            longitude_t: nil,
            description: nil,
            is_active: nil,
            created_f: nil,
            created_t: nil
end
