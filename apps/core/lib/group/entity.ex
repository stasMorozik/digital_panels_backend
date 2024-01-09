defmodule Core.Group.Entity do
    @moduledoc """
    Сущность - группа
  """

  alias Core.Group.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    sum: integer(),
    devices: list(Core.Device.Entity.t()),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            name: nil,
            sum: nil,
            devices: nil, 
            created: nil, 
            updated: nil
end