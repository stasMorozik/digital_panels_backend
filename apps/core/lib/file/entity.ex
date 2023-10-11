defmodule Core.File.Entity do
  @moduledoc """
    Сущность - файл
  """

  alias Core.File.Entity

  @type t :: %Entity{
    id: binary(),
    size: pos_integer(),
    path: binary(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            size: nil,
            path: nil,
            created: nil,
            updated: nil
end
