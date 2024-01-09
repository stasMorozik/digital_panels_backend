defmodule Core.Schedule.Entity do
  @moduledoc """
    Сущность - расписание
  """

  alias Core.Schedule.Entity

  @type t :: %Entity{
    id: binary(),
    name: binary(),
    timings: list(Core.Schedule.Types.Timing.t()),
    group: Core.Group.Entity.t(),
    created: nil,
    updated: nil
  }

  defstruct id: nil, 
            name: nil, 
            timings: nil,
            group: nil,
            created: nil,
            updated: nil
end