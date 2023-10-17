defmodule Core.Shared.Types.Pagination do

  alias Core.Shared.Types.Pagination

  @type t :: %Pagination{
    page: integer(),
    limit: integer()
  }

  defstruct page: 1, limit: 10
end
