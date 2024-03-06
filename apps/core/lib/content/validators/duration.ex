defmodule Core.Content.Validators.Duration do
  @moduledoc """
    Валидирует время показа 
  """

  @min 5
  @max 30

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(duration) when is_integer(duration) do
    with true <- duration >= @min,
         true <- duration <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидное время показа"}
    end
  end

  def valid(_) do
    {:error, "Невалидное время показа"}
  end
end