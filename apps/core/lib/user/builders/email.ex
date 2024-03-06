defmodule Core.User.Builders.Email do
  
  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, email) do    
    case Core.Shared.Validators.Email.valid(email) do
      {:ok, _} -> {:ok, Map.put(entity, :email, email)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _) do
    {:error, message}
  end
end