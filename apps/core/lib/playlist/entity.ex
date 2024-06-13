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
      fun = fn {key, value}, acc ->
        case value do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end

      contents = case Map.get(value, :contents) do
        nil -> 
          nil
        contents -> 
          Enum.map(contents, fn c -> 
            file = Map.from_struct(c.file)
            file = Map.to_list(file)
            file = List.foldr(file, %{}, fun)

            content = Map.from_struct(c)
            content = Map.delete(content, :file)

            content = Map.put(content, :file, file)
            content = Map.to_list(content)

            List.foldr(content, %{}, fun)
          end)
      end

      playlist = Map.from_struct(value)
      playlist = Map.delete(playlist, :contents)

      playlist = Map.put(playlist, :contents, contents)

      playlist = Map.to_list(playlist)
      
      playlist = List.foldr(playlist, %{}, fun)

      Jason.Encode.map(playlist, opts)
    end
  end
end