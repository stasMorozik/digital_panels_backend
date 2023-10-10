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

  defstruct id: nil, email: nil, name: nil, surname: nil, created: nil, updated: nil
end
