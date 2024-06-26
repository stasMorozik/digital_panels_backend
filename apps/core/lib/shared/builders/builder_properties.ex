defmodule Core.Shared.Builders.BuilderProperties do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), atom(), atom(), atom(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, validator, setter, key, value) do
    case validator.valid(value) do
      {:ok, _} -> {:ok, setter.(entity, key, value)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _, _, _, _) do
    {:error, message}
  end
end