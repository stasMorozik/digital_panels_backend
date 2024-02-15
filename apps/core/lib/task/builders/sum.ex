defmodule Core.Task.Builders.Sum do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, {start_hour, start_minute}, {end_hour, end_minute}) do
    with {:ok, true} <- Core.Task.Validators.Hour.valid(start_hour),
         {:ok, true} <- Core.Task.Validators.Minute.valid(start_minute),
         sum_start <- (start_hour * 60) + start_minute,
         {:ok, true} <- Core.Task.Validators.Hour.valid(end_hour),
         {:ok, true} <- Core.Task.Validators.Minute.valid(end_minute),
         sum_end <- (end_hour * 60) + end_minute,
         {:ok, true} <- Core.Task.Validators.Sum.valid(sum_start, sum_end) do
      {:ok, Map.put(entity, :sum, sum_end - sum_start)}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end