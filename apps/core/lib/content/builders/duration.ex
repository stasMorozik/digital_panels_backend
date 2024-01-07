defmodule Core.Content.Builders.Duration do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, duration) do    
    case Core.Content.Validators.Duration.valid(duration) do
      {:ok, _} -> {:ok, Map.put(entity, :duration, duration)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end