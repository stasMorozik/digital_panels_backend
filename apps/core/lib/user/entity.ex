defmodule Core.User.Entity do
  @moduledoc """
    Сущность - пользователь
  """

  alias Core.User.Entity

  @type t :: %Entity{
    id: binary(),
    email: binary(),
    name: binary(),
    surname: binary(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil, 
            email: nil, 
            name: nil, 
            surname: nil, 
            created: nil, 
            updated: nil

  defimpl Jason.Encoder, for: Core.User.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [
        :id, 
        :email, 
        :name, 
        :surname, 
        :created, 
        :updated
      ]), opts)
    end
  end
end
