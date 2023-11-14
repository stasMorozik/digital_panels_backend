defmodule Core.Playlist.Types.Builders.Sort do
  @moduledoc """

  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Shared.Validators.Sort, as: ValidatorSort
  alias Core.Playlist.Types.Sort, as: TypeSort

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    created: created,
    name:   name
  } = map) do
    type()
      |> is_nil(map, :created)
      |> created(created)
      |> is_nil(map, :name)
      |> name(name)
  end

  def build(_) do
    Error.new("Не валидные данные для сортировки")
  end

  defp type do
    Success.new(%TypeSort{
      name: nil,
      created:   nil
    })
  end

  defp is_nil({:ok, type}, map, key) do
    case Map.get(map, key) do
      nil -> {:nil, type}
      _ -> {:ok, type}
    end
  end

  defp name({:ok, type}, name) do
    case ValidatorSort.valid(name) do
      {:ok, _} -> Success.new(Map.put(type, :name, name))
      {:error, message} -> {:error, message}
    end
  end

  defp name({:nil, type}, _) do
    {:ok, type}
  end

  defp name({:error, message}, _) do
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