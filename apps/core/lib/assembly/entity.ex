defmodule Core.Assembly.Entity do
  @moduledoc """
    Тип - тайминг
  """

  alias Core.Assembly.Entity

  @type t :: %Entity{
    id: binary(),
    group: Core.Group.Entity.t(),
    url: binary(),
    type: binary(),
    status: boolean(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            group: nil,
            url: nil,
            type: nil,
            status: false,
            created: nil,
            updated: nil
end