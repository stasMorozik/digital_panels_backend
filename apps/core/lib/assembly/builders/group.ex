defmodule Core.Assembly.Builders.Group do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, group) do    
    case Core.Assembly.Validators.Group.valid(group) do
      {:ok, _} -> {:ok, Map.put(entity, :group, group)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end