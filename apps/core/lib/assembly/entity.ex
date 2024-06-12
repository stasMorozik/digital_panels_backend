defmodule Core.Assembly.Entity do
  @moduledoc """
    Тип - тайминг
  """

  alias Core.Assembly.Entity

  @type t :: %Entity{
    id: binary(),
    group: Core.Group.Entity.t(),
    url: binary(),
    type: binary(),
    status: boolean(),
    access_token: binary(),
    refresh_token: binary(),
    created: binary(),
    updated: binary()
  }

  defstruct id: nil,
            group: nil,
            url: nil,
            type: nil,
            status: nil,
            access_token: nil,
            refresh_token: nil,
            created: nil,
            updated: nil


  defimpl Jason.Encoder, for: Core.Assembly.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [
        :id,
        :group,
        :url,
        :type,
        :status,
        :access_token,
        :refresh_token,
        :created,
        :updated
      ]), opts)
    end
  end
end