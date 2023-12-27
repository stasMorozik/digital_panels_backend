defmodule Core.User.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{email: email, name: name, surname: surname}) do
    entity()
      |> Core.User.Builders.Email.build(email)
      |> Core.User.Builders.Name.build(:name, name)
      |> Core.User.Builders.Name.build(:surname, surname)
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
