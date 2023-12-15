defmodule Core.Shared.Types.Pagination do

  @type t :: %Core.Shared.Types.Pagination{
    page: integer(),
    limit: integer()
  }

  defstruct page: 1, limit: 10
end
