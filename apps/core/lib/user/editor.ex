defmodule Core.User.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.User.Entity

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Shared.Validators.Email
  alias Core.User.Validators.Name

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    setter = fn (entity, key, value) -> 
      Map.put(entity, key, value) 
    end

    entity(entity)
      |> email(Map.get(args, :email), setter)
      |> name(Map.get(args, :name), setter)
      |> surname(Map.get(args, :surname), setter)
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования пользователя"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Core.User.Entity{
      id: entity.id,
      created: entity.created,
      email: entity.email,
      name: entity.name,
      surname: entity.surname,
      updated: Date.utc_today
    }}
  end

  defp email({:ok, entity}, email, setter) do
    case email do
      nil -> {:ok, entity}
      email -> BuilderProperties.build({:ok, entity}, Email, setter, :email, email)
    end
  end

  defp email({:error, message}, _, _) do
    {:error, message}
  end

  defp name({:ok, entity}, name, setter) do
    case name do
      nil -> {:ok, entity}
      name -> BuilderProperties.build({:ok, entity}, Name, setter, :name, name)
    end
  end

  defp name({:error, message}, _, _) do
    {:error, message}
  end

  defp surname({:ok, entity}, surname, setter) do
    case surname do
      nil -> {:ok, entity}
      surname -> BuilderProperties.build({:ok, entity}, Name, setter, :surname, surname)
    end
  end

  defp surname({:error, message}, _, _) do
    {:error, message}
  end
end