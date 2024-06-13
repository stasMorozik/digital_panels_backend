defmodule Core.Content.Entity do

  @type t :: %Core.Content.Entity{
    id: binary(),
    name: binary(),
    duration: integer(),
    file: Core.File.Entity.t(),
    playlist: Core.Playlist.Entity.t(),
    serial_number: integer(),
    created: binary(),
    updated: binary(),
  }

  defstruct id: nil,
            name: nil,
            duration: nil,
            file: nil,
            playlist: nil,
            serial_number: nil,
            created: nil,
            updated: nil

  defimpl Jason.Encoder, for: Core.Content.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      fun = fn {key, value}, acc ->
        case value do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end

      file = case Map.get(value, :file) do
        nil -> nil
        file -> List.foldr(Map.to_list(Map.from_struct(file)) , %{}, fun)
      end

      playlist = case Map.get(value, :playlist) do
        nil -> nil
        playlist -> List.foldr(Map.to_list(Map.from_struct(playlist)), %{}, fun)
      end

      content = Map.from_struct(value)

      content = Map.delete(content, :file)
      content = Map.delete(content, :playlist)

      content = Map.put(content, :file, file)
      content = Map.put(content, :playlist, playlist)

      content = Map.to_list(content)
      
      content = List.foldr(content, %{}, fun)

      Jason.Encode.map(content, opts)
    end
  end
end