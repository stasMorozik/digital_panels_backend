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
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, ip: nil, latitude: nil, longitude: nil, created: nil, updated: nil
end
