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
end
