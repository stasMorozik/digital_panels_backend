defmodule Core.Task.Validators.MonthDay do
  
  @min 1
  @max 31

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(month_day) when is_integer(month_day) do
    with true <- month_day >= @min,
         true <- month_day <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидный день месяца показа"}
    end
  end

  def valid(_) do
    {:error, "Невалидный день месяца показа"}
  end
end