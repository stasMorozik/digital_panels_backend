defmodule Core.ConfirmationCode.Methods.Confirmation do
  @moduledoc """
    Подтверждает код, если прошел верификацию
  """

  alias Core.ConfirmationCode.Methods.Verifier

  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec confirm(Entity.t(), integer()) :: Success.t() | Error.t()
  def confirm(entity, some_code) when is_integer(some_code) and is_struct(entity) do
    with {:ok, _} <- Verifier.verify(entity, some_code) do
      Success.new(Map.put(entity, :confirmed, true))
    else
      {:error, error} -> {:error, error}
    end
  end

  def confirm(_, _) do
    Error.new("Не валидные данные для подтверждения кода")
  end
end
