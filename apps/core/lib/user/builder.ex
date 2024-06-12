defmodule Core.User.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.Shared.Builders.BuilderProperties

  alias Core.Shared.Validators.Email
  alias Core.User.Validators.Name

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{email: email, name: name, surname: surname}) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity()
      |> BuilderProperties.build(Email, setter, :email, email)
      |> BuilderProperties.build(Name, setter, :name, name)
      |> BuilderProperties.build(Name, setter, :surname, surname)
  end

  def build(_) do
    {:error, "Невалидные данные для построения пользователя"}
  end

  # Функция построения базового пользователя
  defp entity do
    {:ok, %Core.User.Entity{
      id: UUID.uuid4(), 
      created: Date.utc_today, 
      updated: Date.utc_today
    }}
  end
end
