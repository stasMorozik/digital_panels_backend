defmodule Core.Task.Builders.Start do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, {start_hour, start_minute}) do
    with fun_0 <- fn (hour) ->
            case hour == 24 do
              true -> 0
              false -> hour
            end
         end,
         {:ok, true} <- Core.Task.Validators.Hour.valid(start_hour),
         {:ok, true} <- Core.Task.Validators.Minute.valid(start_minute),
         start_hour <- fun_0.(start_hour),
         minutes <- (start_hour * 60) + start_minute do
      {:ok, Map.put(entity, :start, minutes)}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end