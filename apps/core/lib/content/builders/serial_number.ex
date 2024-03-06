defmodule Core.Content.Builders.SerialNumber do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, serial_number) do    
    case Core.Content.Validators.SerialNumber.valid(serial_number) do
      {:ok, _} -> {:ok, Map.put(entity, :serial_number, serial_number)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end