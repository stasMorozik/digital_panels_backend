defmodule Core.File.Builders.Size do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias FileSize

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, size) do
    case Core.File.Validators.Size.valid(size) do
      {:ok, _} -> {:ok, Map.put(entity, :size, FileSize.value_to_float(size))}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end