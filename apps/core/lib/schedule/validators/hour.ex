defmodule Core.Schedule.Validators.Hour do
  
  @min 1
  @max 24

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(hour) when is_integer(hour) do
    with true <- hour >= @min,
         true <- hour <= @max do
      {:ok, true}
    else
      false -> {:error, "Невалидный час начала показа плэйлиста"}
    end
  end

  def valid(_) do
    {:error, "Невалидный час начала показа плэйлиста"}
  end
end