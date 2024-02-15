defmodule Core.Task.Builders.End do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, {end_hour, end_minute}) do
    with fun_0 <- fn (hour) ->
            case hour == 24 do
              true -> 0
              false -> hour
            end
         end,
         {:ok, true} <- Core.Task.Validators.Hour.valid(end_hour),
         {:ok, true} <- Core.Task.Validators.Minute.valid(end_minute),
         end_hour <- fun_0.(end_hour),
         minutes <- (end_hour * 60) + end_minute do
      {:ok, Map.put(entity, :end, minutes)}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end