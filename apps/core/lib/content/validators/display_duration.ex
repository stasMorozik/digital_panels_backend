defmodule Core.Content.Validators.DisplayDuration do
	@moduledoc """
    Валидирует порт время показа
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @min 10
  @max 60

  @spec valid(integer()) :: Success.t() | Error.t()
  def valid(duration) when is_integer(duration) do
    with true <- duration >= @min,
         true <- duration <= @max do
      Success.new(true)
    else
      false -> Error.new("Не валидное время показа")
    end
  end

  def valid(_) do
    Error.new("Не валидное время показа")
  end
end