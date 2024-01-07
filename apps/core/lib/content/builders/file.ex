defmodule Core.Content.Builders.File do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), Core.File.Entity.t()) :: Success.t() | Error.t()
  def build({:ok, entity}, %Core.File.Entity{} = file) do    
    {:ok, Map.put(entity, :file, file)}
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end