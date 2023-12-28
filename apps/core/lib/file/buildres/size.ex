defmodule Core.File.Builders.Size do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias FileSize

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, tuple) do
    case Core.File.Validators.Size.valid(tuple) do
      {:ok, _} -> {:ok, Map.put(entity, :size, FileSize.to_integer(elem(tuple, 1)))}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end