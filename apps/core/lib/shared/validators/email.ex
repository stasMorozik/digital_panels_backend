defmodule Core.Shared.Validators.Email do
  @moduledoc """
    Валидирует электронный адрес почты
  """

  @format ~r/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(email) when is_binary(email) do
    case String.match?(email, @format) do
      true -> {:ok, true}
      false -> {:error, "Невалидный адрес электронной почты"}
    end
  end

  def valid(_) do
    {:error, "Невалидный адрес электронной почты"}
  end
end
