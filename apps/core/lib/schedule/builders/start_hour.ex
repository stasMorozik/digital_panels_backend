defmodule Core.Schedule.Builders.StartHour do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, start_hour) do
    case Core.Schedule.Validators.Hour.valid(start_hour) do
      {:ok, _} -> {:ok, Map.put(entity, :start_hour, start_hour)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end