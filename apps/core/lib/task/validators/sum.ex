defmodule Core.Task.Validators.Sum do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec valid(tuple()) :: Success.t() | Error.t()
  def valid({{start_hour, start_minute}, {end_hour, end_minute}}) do
    with fun <- fn (hour) ->
            case hour == 24 do
              true -> 0
              false -> hour
            end
         end,
         {:ok, true} <- Core.Task.Validators.Hour.valid(start_hour),
         {:ok, true} <- Core.Task.Validators.Minute.valid(start_minute),
         start_hour <- fun.(start_hour),
         sum_start <- (start_hour * 60) + start_minute,
         {:ok, true} <- Core.Task.Validators.Hour.valid(end_hour),
         {:ok, true} <- Core.Task.Validators.Minute.valid(end_minute),
         end_hour <- fun.(end_hour),
         sum_end <- (end_hour * 60) + end_minute,
         {:ok, true} <- Core.Task.Validators.Covering.valid(sum_start, sum_end) do
      {:ok, true}
    else
      {:error, message} -> {:error, message}
    end
  end
end