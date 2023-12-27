defmodule Core.Device.Builders.Ip do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, ip) do    
    case Core.Device.Validators.Ip.valid(ip) do
      {:ok, _} -> {:ok, Map.put(entity, :ip, ip)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end