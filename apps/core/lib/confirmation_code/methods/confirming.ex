defmodule Core.ConfirmationCode.Methods.Confirming do
  @moduledoc """
    Подтверждает код, если прошел верификацию
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.ConfirmationCode.Entity

  alias Core.ConfirmationCode.Validators.Code

  @spec confirm(Entity.t(), any()) :: Success.t() | Error.t()
  def confirm(%Entity{} = entity, some_code) do
    with {:ok, cur_utc_date} <- DateTime.now("Etc/UTC"),
         cur_unix_time <- DateTime.to_unix(cur_utc_date),
         false <- cur_unix_time > entity.created,
         {:ok, _} <- Code.valid(some_code),
         true <- entity.code == some_code do

      {:ok, Map.put(entity, :confirmed, true)}
      
    else
      true -> {:error, "Истекло время жизни у кода подтверждения"}
      false -> {:error, "Не верный код подтверждения"}
      {:error, message} -> {:error, message}
    end
  end

  def confirm(_, _) do
    {:error, "Не валидные данные для подтверждения кода"}
  end
end
