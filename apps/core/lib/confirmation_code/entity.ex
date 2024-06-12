defmodule Core.ConfirmationCode.Entity do
  @moduledoc """
    Сущность - код подтверждения
  """

  alias Core.ConfirmationCode.Entity

  @type t :: %Entity{
    needle: binary(), 
    created: integer(), 
    code: integer(), 
    confirmed: boolean()
  }

  defstruct needle: nil, created: nil, code: nil, confirmed: nil

  defimpl Jason.Encoder, for: Core.ConfirmationCode.Entity do
    @impl Jason.Encoder

    def encode(value, opts) do
      Jason.Encode.map(Map.take(value, [
        :needle,
        :created,
        :code,
        :confirmed
      ]), opts)
    end
  end
end
