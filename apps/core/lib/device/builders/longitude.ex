defmodule Core.Device.Builders.Longitude do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, {key, longitude}) do    
    case Core.Device.Validators.Longitude.valid(longitude) do
      {:ok, _} -> {:ok, Map.put(entity, key, longitude)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:ok, entity}, longitude) do    
    case Core.Device.Validators.Longitude.valid(longitude) do
      {:ok, _} -> {:ok, Map.put(entity, :longitude, longitude)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end