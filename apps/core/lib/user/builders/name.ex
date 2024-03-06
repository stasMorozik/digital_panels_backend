defmodule Core.User.Builders.Name do

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(Success.t() | Error.t(), atom(), any()) :: Success.t() | Error.t()
  def build({:ok, entity}, :name, name) do    
    case Core.User.Validators.Name.valid(name) do
      {:ok, _} -> {:ok, Map.put(entity, :name, name)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:ok, entity}, :surname, surname) do    
    case Core.User.Validators.Name.valid(surname) do
      {:ok, _} -> {:ok, Map.put(entity, :surname, surname)}
      {:error, message} -> {:error, message}
    end
  end

  def build({:error, message}, _, _) do
    {:error, message}
  end
end