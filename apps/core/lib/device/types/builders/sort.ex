defmodule Core.Device.Types.Builders.Sort do
  @moduledoc """

  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Shared.Validators.Sort, as: ValidatorSort
  alias Core.Device.Types.Sort, as: TypeSort

  def build(%{
    is_active: is_active,
    created:   created
  } = map) do
    type()
      |> is_nil(map, :is_active)
      |> is_active(is_active)
      |> is_nil(map, :created)
      |> created(created)
  end

  def build(_) do
    Error.new("Не валидные данные для сортировки")
  end

  defp type do
    Success.new(%TypeSort{
      is_active: nil,
      created:   nil
    })
  end

  defp is_nil({:ok, type}, map, key) do
    case Map.get(map, key) do
      nil -> {:nil, type}
      _ -> {:ok, type}
    end
  end

  defp is_active({:ok, type}, is_active) do
    case ValidatorSort.valid(is_active) do
      {:ok, _} -> Success.new(Map.put(type, :is_active, is_active))
      {:error, message} -> {:error, message}
    end
  end

  defp is_active({:nil, type}, _) do
    {:ok, type}
  end

  defp is_active({:error, message}, _) do
    {:error, message}
  end

  defp created({:ok, type}, created) do
    case ValidatorSort.valid(created) do
      {:ok, _} -> Success.new(Map.put(type, :created, created))
      {:error, message} -> {:error, message}
    end
  end

  defp created({:nil, type}, _) do
    {:ok, type}
  end

  defp created({:error, message}, _) do
    {:error, message}
  end
end