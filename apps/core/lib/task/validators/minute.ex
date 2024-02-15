defmodule Core.Task.Validators.Minute do
  
  @min 0
  @max 59

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(minute) when is_integer(minute) do
    with true <- minute >= @min,
         true <- minute <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидные минуты показа"}
    end
  end

  def valid(_) do
    {:error, "Невалидные минуты показа"}
  end
end