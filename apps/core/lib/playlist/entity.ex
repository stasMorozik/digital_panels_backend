defmodule Core.Playlist.Entity do
  @moduledoc """
    Сущность - плэйлист
  """

  alias Core.Playlist.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    sum: integer(),
    contents: list(Core.Playlist.Types.Content.t()),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            name: nil,
            sum: nil,
            contents: nil,
            created: nil,
            updated: nil

  defimpl Jason.Encoder, for: Core.Playlist.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [
        :id, 
        :name,
        :sum,
        :devices, 
        :created, 
        :updated
      ]), opts)
    end
  end
end