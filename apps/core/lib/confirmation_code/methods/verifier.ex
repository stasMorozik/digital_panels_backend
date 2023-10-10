defmodule Core.ConfirmationCode.Methods.Verifier do
  @moduledoc """
    Верифицирует код, проверяет не стекло ли время жизни,
    а так же сверяет код с тем что прислал пользователь
  """

  alias Core.ConfirmationCode.Entity
  alias Core.ConfirmationCode.Validators.Code

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec verify(Entity.t(), integer()) :: Success.t() | Error.t()
  def verify(%Entity{created: created, confirmed: _, code: code, needle: _}, some_code) when is_integer(some_code) do
    {:ok, cur_utc_date} = DateTime.now("Etc/UTC")

    cur_unix_time = DateTime.to_unix(cur_utc_date)

    if cur_unix_time > created do
      Error.new("Истекло время жизни у кода подтверждения")
    else
      with {:ok, _} <- Code.valid(some_code),
           true <- code == some_code do
        Success.new(true)
      else
        {:error, error} -> {:error, error}
        false -> Error.new("Не верный код подтверждения")
      end
    end
  end

  def verify(_, _) do
    Error.new("Не валидные данные для верификации кода")
  end
end
