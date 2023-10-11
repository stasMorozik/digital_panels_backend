defmodule Core.Content.Entity do
  @moduledoc """
    Сущность - контент
  """

  alias Core.Content.Entity, as: ContentEntity
  alias Core.File.Entity, as: FileEntity

  @type t :: %ContentEntity{
    id: binary(),
    display_duration: float(),
    file: FileEntity.t(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            display_duration: nil,
            file: nil,
            created: nil,
            updated: nil
end
