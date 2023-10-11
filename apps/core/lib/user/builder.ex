defmodule Core.User.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias UUID
  alias Core.User.Entity
  alias Core.Shared.Validators.Email
  alias Core.User.Validators.Name

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{email: email, name: name, surname: surname}) do
    entity()
      |> email(email)
      |> name(name)
      |> surname(surname)
  end

  def build(_) do
    Error.new("Не валидные данные для построения пользователя")
  end

  # Функция построения базового пользователя
  defp entity do
    Success.new(%Entity{id: UUID.uuid4(), created: Date.utc_today, updated: Date.utc_today})
  end

  # Функция построения электронной почты пользователя
  defp email({ :ok, entity }, new_email) when is_struct(entity) do
    case Email.valid(new_email) do
      {:ok, _} -> Success.new(Map.put(entity, :email, new_email))
      {:error, error} -> {:error, error}
    end
  end

  defp email({:error, message}, _) when is_binary(message) do
    {:error, message}
  end

  # Функция построения имени пользователя
  defp name({ :ok, entity }, new_name) when is_struct(entity) do
    case Name.valid(new_name) do
      {:ok, _} -> Success.new(Map.put(entity, :name, new_name))
      {:error, error} -> {:error, error}
    end
  end

  defp name({:error, message}, _) when is_binary(message) do
    {:error, message}
  end

  #  Функция построения фамилии пользователя
  defp surname({ :ok, entity }, new_surname) when is_struct(entity) do
    case Name.valid(new_surname) do
      {:ok, _} -> Success.new(Map.put(entity, :surname, new_surname))
      {:error, _} -> Error.new("Не валидная фамилия пользователя")
    end
  end

  defp surname({:error, message}, _) when is_binary(message) do
    {:error, message}
  end
end
