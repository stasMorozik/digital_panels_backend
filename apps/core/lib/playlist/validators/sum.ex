defmodule Core.Playlist.Validators.Sum do
  @moduledoc """
    Валидирует количество контента
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @min 1
  @max 20

  @spec valid(any()) :: Success.t() | Error.t()
  def valid(sum) when is_integer(sum) do
    with true <- sum >= @min,
         true <- sum <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидное количество контента"}
    end
  end

  def valid(_) do
    {:error, "Невалидное количество контента"}
  end
end