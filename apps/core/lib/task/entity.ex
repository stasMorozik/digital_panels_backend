defmodule Core.Task.Entity do
  @moduledoc """
    Тип - тайминг
  """

  alias Core.Task.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    playlist: Core.Playlist.Entity.t(),
    group: Core.Group.Entity.t(),
    type: binary(),
    day: integer(),
    start_hour: integer(),
    end_hour: integer(),
    start_minute: integer(),
    end_minute: integer(),
    start: integer(),
    end: integer(),
    sum: integer(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            name: nil,
            playlist: nil,
            group: nil,
            type: nil,
            day: nil,
            start_hour: nil,
            end_hour: nil,
            start_minute: nil,
            end_minute: nil,
            start: nil,
            end: nil,
            sum: nil,
            created: nil,
            updated: nil

  defimpl Jason.Encoder, for: Core.Task.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      fun = fn {key, value}, acc ->
        case value do
          nil -> acc
          value -> Map.put(acc, key, value)
        end
      end

      group = case Map.get(value, :group) do
        nil -> nil
        group -> List.foldr(Map.to_list(Map.from_struct(group)), %{}, fun)
      end

      playlist = case Map.get(value, :playlist) do
        nil -> 
          nil
        playlist -> 
          

          contents = Enum.map(playlist.contents, fn c -> 
            file = Map.from_struct(c.file)
            file = Map.to_list(file)
            file = List.foldr(file, %{}, fun)

            content = Map.from_struct(c)
            content = Map.delete(content, :file)

            content = Map.put(content, :file, file)
            content = Map.to_list(content)

            List.foldr(content, %{}, fun)
          end)

          playlist = Map.from_struct(playlist)
          playlist = Map.delete(playlist, :contents)
          playlist = Map.put(playlist, :contents, contents)

          playlist = Map.to_list(playlist)
      
          List.foldr(playlist, %{}, fun)
      end

      task = Map.from_struct(value)
      task = Map.delete(task, :playlist)

      task = Map.put(task, :playlist, playlist)

      task = Map.to_list(task)
      
      task = List.foldr(task, %{}, fun)

      Jason.Encode.map(task, opts)
    end
  end
end