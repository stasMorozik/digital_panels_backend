defmodule Core.Device.Builders.Latitude do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, latitude) do    
    case Core.Device.Validators.Latitude.valid(latitude) do
      {:ok, _} -> {:ok, Map.put(entity, :latitude, latitude)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end