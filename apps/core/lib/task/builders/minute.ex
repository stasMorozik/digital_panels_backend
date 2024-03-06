defmodule Core.Task.Builders.Minute do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, {:start, minute}) do
    case Core.Task.Validators.Minute.valid(minute) do
      {:ok, _} -> {:ok, Map.put(entity, :start_minute, minute)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:ok, entity}, {:end, minute}) do
    case Core.Task.Validators.Minute.valid(minute) do
      {:ok, _} -> {:ok, Map.put(entity, :end_minute, minute)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end