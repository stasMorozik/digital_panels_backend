defmodule Core.User.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.User.Entity

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    entity(entity)
      |> email(Map.get(args, :email))
      |> name(Map.get(args, :name))
      |> surname(Map.get(args, :surname))
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

  defp email({:ok, entity}, email) do
    case email do
      nil -> {:ok, entity}
      email -> Core.User.Builders.Email.build({:ok, entity}, email)
    end
  end

  defp email({:error, message}, _) do
    {:error, message}
  end

  defp name({:ok, entity}, name) do
    case name do
      nil -> {:ok, entity}
      name -> Core.User.Builders.Name.build({:ok, entity}, :name, name)
    end
  end

  defp name({:error, message}, _) do
    {:error, message}
  end

  defp surname({:ok, entity}, surname) do
    case surname do
      nil -> {:ok, entity}
      surname -> Core.User.Builders.Name.build({:ok, entity}, :surname, surname)
    end
  end

  defp surname({:error, message}, _) do
    {:error, message}
  end
end