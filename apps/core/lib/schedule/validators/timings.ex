defmodule Core.Schedule.Validators.Timings do
  
  @min 1
  @max 144

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(timings) when is_list(timings) do
    with leng <- length(timings),
         true <- leng >= @min,
         true <- leng <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидный список таймингов"}
    end
  end

  def valid(_) do
    {:error, "Невалидный список таймингов"}
  end
end