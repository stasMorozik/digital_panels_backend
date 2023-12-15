defmodule Core.ConfirmationCode.Builder do
  @moduledoc """
    Билдер сущности
  """

  alias Core.ConfirmationCode.Entity

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  @doc """
    Функция построения сущнсоти
  """
  @spec build(any(), atom()) :: Success.t() | Error.t()
  def build(needle, validator) when is_atom(validator) do
    entity() |> Core.ConfirmationCode.Builders.Needle.build(validator, needle)
  end

  def build(_, _) do
    {:ok, "Не валидные данные для построения кода подтверждения"}
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
