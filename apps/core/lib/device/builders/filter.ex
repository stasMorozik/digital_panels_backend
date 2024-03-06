defmodule Core.Device.Builders.Filter do

  alias Core.Device.Builders.Ip
  alias Core.Device.Builders.Latitude
  alias Core.Device.Builders.Longitude
  alias Core.Device.Builders.Description

  alias Core.Device.Types.Filter

  alias Core.Shared.Validators.Date

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    filter()
      |> ip(Map.get(args, :ip))
      |> latitude_f(Map.get(args, :latitude_f))
      |> latitude_t(Map.get(args, :latitude_t))
      |> longitude_f(Map.get(args, :longitude_f))
      |> longitude_t(Map.get(args, :longitude_t))
      |> description(Map.get(args, :description))
      |> created_f(Map.get(args, :created_f))
      |> created_t(Map.get(args, :created_t))
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Filter{}}
  end

  defp ip({:ok, filter}, ip) do
    case ip do
      nil -> {:ok, filter}
      ip -> Ip.build({:ok, filter}, ip)
    end
  end

  defp ip({:error, message}, _) do
    {:error, message}
  end

  defp latitude_f({:ok, filter}, latitude_f) do
    case latitude_f do
      nil -> {:ok, filter}
      latitude_f -> Latitude.build({:ok, filter}, latitude_f)
    end
  end

  defp latitude_f({:error, message}, _) do
    {:error, message}
  end

  defp latitude_t({:ok, filter}, latitude_t) do
    case latitude_t do
      nil -> {:ok, filter}
      latitude_t -> Latitude.build({:ok, filter}, latitude_t)
    end
  end

  defp latitude_t({:error, message}, _) do
    {:error, message}
  end

  defp longitude_f({:ok, filter}, longitude_f) do
    case longitude_f do
      nil -> {:ok, filter}
      longitude_f -> Longitude.build({:ok, filter}, longitude_f)
    end
  end

  defp longitude_f({:error, message}, _) do
    {:error, message}
  end

  defp longitude_t({:ok, filter}, longitude_t) do
    case longitude_t do
      nil -> {:ok, filter}
      longitude_t -> Longitude.build({:ok, filter}, longitude_t)
    end
  end

  defp longitude_t({:error, message}, _) do
    {:error, message}
  end

  defp description({:ok, filter}, description) do
    case description do
      nil -> {:ok, filter}
      description -> Description.build({:ok, filter}, description)
    end
  end

  defp description({:error, message}, _) do
    {:error, message}
  end

  defp created_f({:ok, filter}, created_f) do
    with false <- created_f == nil,
         {:ok, _} <- Date.valid(created_f) do
      {:ok, Map.put(filter, :created_f, created_f)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp created_f({:error, message}, _) do
    {:error, message}
  end

  defp created_t({:ok, filter}, created_t) do
    with false <- created_t == nil,
         {:ok, _} <- Date.valid(created_t) do
      {:ok, Map.put(filter, :created_t, created_t)}
    else
      true -> {:ok, filter}
      {:error, message} -> {:error, message}
    end
  end

  defp created_t({:error, message}, _) do
    {:error, message}
  end
end