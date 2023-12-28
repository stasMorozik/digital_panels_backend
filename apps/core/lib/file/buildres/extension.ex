defmodule Core.File.Builders.Extension do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, extname) do
    case Core.File.Validators.Extension.valid(extname) do
      {:ok, _} -> {:ok, Map.put(entity, :extension, extname)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end