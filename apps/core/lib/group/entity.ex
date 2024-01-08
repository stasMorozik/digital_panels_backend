defmodule Core.Group.Entity do
    @moduledoc """
    Сущность - группа
  """

  alias Core.Group.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    devices: list(Core.Device.Entity.t()),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            name: nil, 
            devices: [], 
            created: nil, 
            updated: nil
end