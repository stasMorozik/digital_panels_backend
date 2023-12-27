defmodule Core.Shared.Builders.Pagi do

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
      false -> {:error, "Невалидные данные для пагинации"}
    end
  end

  def build(_) do
    {:error, "Невалидные данные для пагинации"}
  end
end
