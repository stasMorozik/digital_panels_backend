defmodule Core.Group.Builders.Sum do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, sum) do
    with {:ok, true} <- Core.Group.Validators.Sum.valid(sum) do
      {:ok, Map.put(entity, :sum, sum)}
    else
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end