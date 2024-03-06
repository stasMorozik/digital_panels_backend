defmodule Core.Device.Entity do
  @moduledoc """
    Сущность - устройство
  """

  alias Core.Device.Entity

  @type t :: %Entity{
    id: binary(),
    ip: binary(),
    latitude: float(),
    longitude: float(),
    desc: binary(),
    group: Core.Group.Entity.t(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            ip: nil, 
            latitude: nil, 
            longitude: nil, 
            desc: nil,
            group: nil,
            created: nil, 
            updated: nil
end
