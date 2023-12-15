defmodule Core.ConfirmationCode.Methods.Verifier do
  @moduledoc """
    Верифицирует код, проверяет не стекло ли время жизни,
    а так же сверяет код с тем что прислал пользователь
  """

  alias Core.ConfirmationCode.Entity
  alias Core.ConfirmationCode.Validators.Code, as: Validator

  @spec verify(Entity.t(), any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def verify(%Entity{} = entity, some_code) do
    with {:ok, cur_utc_date} <- DateTime.now("Etc/UTC"),
         cur_unix_time <- DateTime.to_unix(cur_utc_date),
         false <- cur_unix_time > entity.created,
         {:ok, _} <- Validator.valid(some_code)
         true <- entity.code == some_code do
      {:ok, true}
    else
      true -> {:error, "Истекло время жизни у кода подтверждения"}
      false -> {:error, "Не верный код подтверждения"}
      {:error, message} -> {:error, message}
    end
  end

  def verify(_, _) do
    {:error, "Не валидные данные для верификации кода"}
  end
end
