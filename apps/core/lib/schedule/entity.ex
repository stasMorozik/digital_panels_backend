defmodule Core.Schedule.Entity do
  @moduledoc """
    Сущность - расписание
  """

  alias Core.Schedule.Entity

  @type t :: %Entity{
    id: binary(),
    
    created: binary(),
    updated: binary()
  }
end