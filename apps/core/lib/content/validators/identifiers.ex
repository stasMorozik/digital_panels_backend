defmodule Core.Content.Validators.Identifiers do
  @moduledoc """
    Валидирует список идентификаторов
  """

  alias UUID

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(identifiers) when is_list(identifiers) do
    with validated <- Enum.map(identifiers, fn uuid -> UUID.info(uuid) end),
         filtered <- Enum.filter(validated, fn {result, _} -> result == :error end),
         true <- length(filtered) == 0 do
      {:ok, true}
    else
      false -> {:error, "Невалидный список идентификаторов"}
    end
  end

  def valid(_) do
    {:error, "Невалидный список идентификаторов"}
  end
end