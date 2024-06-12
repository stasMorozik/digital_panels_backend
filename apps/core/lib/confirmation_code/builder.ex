defmodule Core.ConfirmationCode.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias Core.Shared.Builders.BuilderProperties

  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @doc """
    Функция построения сущнсоти
  """
  @spec build(atom(), any()) :: Success.t() | Error.t()
  def build(validator, needle) when is_atom(validator) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity() 
      |> BuilderProperties.build(validator, setter, :needle, needle) 
  end

  def build(_, _) do
    {:ok, "Невалидные данные для построения кода подтверждения"}
  end

  # Функция построения базового кода
  defp entity do
    {:ok, utc_date} = DateTime.now("Etc/UTC")

    {:ok, %Entity {
      created: DateTime.to_unix(utc_date) + 84000,
      confirmed: false,
      code: 1000..9999 |> Enum.random()
    }}
  end
end
