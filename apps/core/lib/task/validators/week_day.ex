defmodule Core.Task.Validators.WeekDay do
  
  @min 1
  @max 7

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(week_day) when is_integer(week_day) do
    with true <- week_day >= @min,
         true <- week_day <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидный день недели показа"}
    end
  end

  def valid(_) do
    {:error, "Невалидный день недели показа"}
  end
end