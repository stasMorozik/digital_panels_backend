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
      Jason.Encode.map(Map.take(value, [
        :id,
        :name,
        :duration,
        :file,
        :playlist,
        :serial_number,
        :created,
        :updated
      ]), opts)
    end
  end
end