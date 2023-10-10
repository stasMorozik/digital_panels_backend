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
  @spec build(binary(), atom()) :: Success.t() | Error.t()
  def build(needle, validator) when is_atom(validator) and is_binary(needle) do
    entity() |> needle(validator, needle)
  end

  def build(_, _) do
    Error.new("Не валидные данные для построения кода подтверждения")
  end

  # Функция построения базового кода
  defp entity do
    {:ok, utc_date} = DateTime.now("Etc/UTC")

    Success.new(%Entity {
      created: DateTime.to_unix(utc_date) + 84000,
      confirmed: false,
      code: 1000..9999 |> Enum.random()
    })
  end

  # Функция построения того что нужно подтвердить(телефон, почта)
  defp needle({ :ok, entity}, validator, new_needle) when is_struct(entity) do
    with true <- Kernel.function_exported?(validator, :valid, 1),
         {:ok, _} <- validator.valid(new_needle) do
      Success.new(Map.put(entity, :needle, new_needle))
    else
      false ->
        Error.new("Не валидные данные для построения кода подтверждения")
      {:error, error} -> {:error, error}
    end
  end

  defp needle({:ok, _}, _, _) do
    Error.new("Не валидные данные для построения кода подтверждения")
  end

  defp needle({:error, error}, _, _) do
    {:error, error}
  end

  defp needle(_, _, _) do
    Error.new("Не валидные данные для построения кода подтверждения")
  end
end
