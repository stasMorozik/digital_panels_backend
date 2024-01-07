defmodule Core.Content.Entity do

  @type t :: %Core.Content.Entity{
    id: binary(),
    name: binary(),
    duration: integer(),
    file: Core.File.Entity.t(),
    created: binary(),
    updated: binary(),
  }

  defstruct id: nil,
            name: nil,
            duration: nil,
            file: nil,
            created: nil,
            updated: nil
end