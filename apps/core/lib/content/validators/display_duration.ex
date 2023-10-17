defmodule Core.Content.Validators.DisplayDuration do
	@moduledoc """
    Валидирует порт время показа
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(integer()) :: Success.t() | Error.t()
  def valid(duration) when is_integer(duration) do
    with true <- duration >= 10,
         true <- duration <= 60 do
      Success.new(true)
    else
      false -> Error.new("Не валидное время показа")
    end
  end

  def valid(_) do
    Error.new("Не валидное время показа")
  end
end