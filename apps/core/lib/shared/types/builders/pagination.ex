defmodule Core.Shared.Types.Builders.Pagi do
  @moduledoc """
    Валидирует данные для пагинации
  """

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(data) when is_map(data) do
    with page <- Map.get(data, :page),
         limit <- Map.get(data, :limit),
         true <- is_integer(page),
         true <- is_integer(limit),
         true <- page > 0,
         true <- limit > 0 do

      {:ok, %Core.Shared.Types.Pagination{
        page: page,
        limit: limit
      }}
    else
      false -> {:error, "Не валидные данные для пагинации"}
    end
  end

  def build(_) do
    {:error, "Не валидные данные для пагинации"}
  end
end
