defmodule Core.Device.Entity do
  @moduledoc """
    Сущность - устройство
  """

  alias Core.Device.Entity

  @type t :: %Entity{
    id: binary(),
    ssh_port: integer(),
    ssh_host: binary(),
    ssh_user: binary(),
    ssh_password: binary(),
    address: binary(),
    longitude: float(),
    latitude: float(),
    is_active: boolean(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            ssh_port: nil,
            ssh_host: nil,
            ssh_user: nil,
            ssh_password: nil,
            address: nil,
            longitude: nil,
            latitude: nil,
            is_active: nil,
            created: nil,
            updated: nil
end
