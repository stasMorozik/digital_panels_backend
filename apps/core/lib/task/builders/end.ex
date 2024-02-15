defmodule Core.Task.Builders.End do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, {end_hour, end_minute}) do
    with {:ok, true} <- Core.Task.Validators.Hour.valid(end_hour),
         {:ok, true} <- Core.Task.Validators.Minute.valid(end_minute),
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