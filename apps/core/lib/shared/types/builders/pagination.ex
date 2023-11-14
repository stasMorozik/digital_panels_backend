defmodule Core.Shared.Types.Builders.Pagi do
  @moduledoc """
    Валидирует данные для пагинации
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Shared.Types.Pagination

  @spec build(map()) :: Success.t() | Error.t()
  def build(data) when is_map(data) do
    with page <- Map.get(data, :page),
         limit <- Map.get(data, :limit),
         true <- is_integer(page),
         true <- is_integer(limit),
         true <- page > 0,
         true <- limit > 0 do

      Success.new(%Pagination{
        page: page,
        limit: limit
      })
    else
      false -> Error.new("Не валидные данные для пагинации")
    end
  end

  def build(_) do
    Error.new("Не валидные данные для пагинации")
  end
end
