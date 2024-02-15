defmodule Core.Shared.Validators.Identifier do
  @moduledoc """
    Валидирует идентификатор
  """

  alias UUID

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(identifier) when is_binary(identifier) do
    with {:ok, _} <- UUID.info(identifier) do
      {:ok, true}
    else
      {:error, _} -> {:error, "Невалидный идентификатор"}
    end
  end

  def valid(_) do
    {:error, "Невалидный идентификатор"}
  end
end