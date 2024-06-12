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
            contents: [],
            created: nil,
            updated: nil

  defimpl Jason.Encoder, for: Core.Playlist.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      contents = Enum.map(value.contents, fn content -> Map.from_struct(content) end)

      value = Map.put(value, contents, contents)

      Jason.Encode.map(Map.from_struct(value), opts)
    end
  end
end