defmodule Core.Group.Builders.Devices do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  
  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, devices) do
    case Core.Group.Validators.Devices.valid(devices) do
      {:ok, _} -> {:ok, Map.put(entity, :devices, devices)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end