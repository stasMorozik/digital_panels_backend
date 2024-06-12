defmodule Core.File.Entity do
  @moduledoc """
    Сущность - файл
  """

  alias Core.File.Entity

  @type t :: %Entity{
    id: binary(),
    path: binary(),
    url: binary(),
    extension: binary(),
    type: binary(),
    size: integer(),
    created: binary()
  }

  defstruct id: nil, 
            path: nil, 
            url: nil, 
            extension: nil, 
            type: nil, 
            size: nil, 
            created: nil

  defimpl Jason.Encoder, for: Core.File.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [
        :id, 
        :path, 
        :url, 
        :extension, 
        :type, 
        :size, 
        :created
      ]), opts)
    end
  end
end