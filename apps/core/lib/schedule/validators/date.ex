defmodule Core.Schedule.Validators.Date do

  @spec valid(any()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def valid(date) when is_integer(date) do
    with current_time <- DateTime.utc_now() |> DateTime.to_unix(),
         true <- date >= current_time,
         true <- date <= (current_time + 2_419_200) do
      {:ok, true}
    else
      false -> {:error, "Невалидная дата показа"}
    end
  end

  def valid(_) do
    {:error, "Невалидная дата показа"}
  end
end