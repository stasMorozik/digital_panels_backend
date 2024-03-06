defmodule Core.Task.Builders.Sum do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), tuple(), tuple()) :: Success.t() | Error.t()
  def build({:ok, entity}, {start_hour, start_minute}, {end_hour, end_minute}) do
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
         {:ok, true} <- Core.Task.Validators.Sum.valid(sum_start, sum_end) do
      {:ok, Map.put(entity, :sum, sum_end - sum_start)}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _, _) do
    {:error, message}
  end
end