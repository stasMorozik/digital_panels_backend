defmodule Core.Schedule.Builders.Timings do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, timings) do    
    case Core.Schedule.Validators.Timings.valid(timings) do
      {:ok, _} -> {:ok, Map.put(entity, :timings, timings)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end