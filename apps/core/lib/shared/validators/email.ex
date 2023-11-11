defmodule Core.Shared.Validators.Email do
  @moduledoc """
    Валидирует электронный адрес почты
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @format ~r/^\w+([\.-]?\w+)*@\w+([\.-]?\w+)*(\.\w{2,3})+$/

  @spec valid(binary()) :: Success.t() | Error.t()
  def valid(email) when is_binary(email) do
    case String.match?(email, @format) do
      true -> Success.new(true)
      false -> Error.new("Не валидный адрес электронной почты")
    end
  end

  def valid(_) do
    Error.new("Не валидный адрес электронной почты")
  end
end
