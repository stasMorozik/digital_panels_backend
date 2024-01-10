defmodule Core.Schedule.Builders.Name do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, name) do
    case Core.Schedule.Validators.Name.valid(name) do
      {:ok, _} -> {:ok, Map.put(entity, :name, name)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end