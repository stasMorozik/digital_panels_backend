defmodule Core.ConfirmationCode.Builders.Needle do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), atom(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, validator, needle) do
    with true <- Kernel.function_exported?(validator, :valid, 1),
         {:ok, _} <- validator.valid(needle) do
      {:ok, Map.put(entity, :needle, needle)}
    else
      false -> {:error, "Невалидные данные для построения кода подтверждения"}
      {:error, error} -> {:error, error}
    end
  end

  def build({:error, message}, _, _) do
    {:error, message}
  end
end