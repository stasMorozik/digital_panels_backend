defmodule Core.Schedule.Builders.Hour do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, {:start, hour}) do
    case Core.Schedule.Validators.Hour.valid(hour) do
      {:ok, _} -> {:ok, Map.put(entity, :start_hour, hour)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:ok, entity}, {:end, hour}) do
    case Core.Schedule.Validators.Hour.valid(hour) do
      {:ok, _} -> {:ok, Map.put(entity, :end_hour, hour)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _, _) do
    {:error, message}
  end
end