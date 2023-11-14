defmodule Core.Playlist.Types.Builders.Filter do
  @moduledoc """

  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error

  alias Core.Shared.Validators.Date

  alias Core.Playlist.Validators.Name

  alias Core.Playlist.Types.Filter

  @spec build(map()) :: Success.t() | Error.t()
  def build(%{
    name:      name,
    created_f: created_f,
    created_t: created_t
  } = map) when is_map(map) do
    type()
      |> is_nil(map, :created_f)
      |> created_f(created_f)
      |> is_nil(map, :created_t)
      |> created_t(created_t)
      |> is_nil(map, :name)
      |> name(name)
  end

  def build(_) do
    Error.new("Не валидные данные для фильтрации")
  end

  defp type do
    Success.new(%Filter{
      user_id:   nil,
      name:      nil,
      created_f: nil,
      created_t: nil
    })
  end

  defp is_nil({:ok, type}, map, key) do
    case Map.get(map, key) do
      nil -> {:nil, type}
      _ -> {:ok, type}
    end
  end

  defp created_f({:ok, type}, date) do
    case Date.valid(date) do
      {:ok, date} -> Success.new(Map.put(type, :created_f, date))
      {:error, message} -> {:error, message}
    end
  end

  defp created_f({:nil, type}, _) do
    {:ok, type}
  end

  defp created_f({:error, message}, _) do
    {:error, message}
  end

  defp created_t({:ok, type}, date) do
    case Date.valid(date) do
      {:ok, date} -> Success.new(Map.put(type, :created_t, date))
      {:error, message} -> {:error, message}
    end
  end

  defp created_t({:nil, type}, _) do
    {:ok, type}
  end

  defp created_t({:error, message}, _) do
    {:error, message}
  end

  defp name({:ok, type}, name) do
    case Name.valid(name) do
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
end