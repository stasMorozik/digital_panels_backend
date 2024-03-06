defmodule Core.Task.Builders.Type do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, type) do
    case Core.Task.Validators.Type.valid(type) do
      {:ok, _} -> {:ok, Map.put(entity, :type, type)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end