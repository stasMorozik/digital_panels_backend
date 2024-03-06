defmodule Core.Device.Builders.Description do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, desc) do    
    case Core.Device.Validators.Description.valid(desc) do
      {:ok, _} -> {:ok, Map.put(entity, :desc, desc)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end