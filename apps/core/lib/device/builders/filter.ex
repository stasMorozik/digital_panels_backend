defmodule Core.Device.Builders.Filter do

  alias Core.Device.Builders.Ip
  alias Core.Device.Builders.Latitude
  alias Core.Device.Builders.Longitude

  alias Core.Device.Types.Filter

  alias Core.Shared.Validators.Date

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    filter()
      |> ip(Map.get(args, :ip))
      |> latitude(Map.get(args, :latitude))
      |> longitude(Map.get(args, :longitude))
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

  defp latitude({:ok, filter}, latitude) do
    case latitude do
      nil -> {:ok, filter}
      latitude -> Latitude.build({:ok, filter}, latitude)
    end
  end

  defp latitude({:error, message}, _) do
    {:error, message}
  end

  defp longitude({:ok, filter}, longitude) do
    case longitude do
      nil -> {:ok, filter}
      longitude -> Longitude.build({:ok, filter}, longitude)
    end
  end

  defp longitude({:error, message}, _) do
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