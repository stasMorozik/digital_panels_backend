defmodule Core.Device.Builders.Filter do

  alias Core.Shared.Builders.BuilderProperties

  alias Core.Device.Validators.Ip
  alias Core.Device.Validators.Latitude
  alias Core.Device.Validators.Longitude
  alias Core.Device.Validators.Description
  alias Core.Shared.Validators.Boolean
  alias Core.Shared.Validators.Date

  alias Core.Device.Types.Filter

  @spec build(map()) :: Core.Shared.Types.Success.t() | Core.Shared.Types.Error.t()
  def build(%{} = args) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    filter()
      |> ip(Map.get(args, :ip), setter)
      |> latitude_f(Map.get(args, :latitude_f), setter)
      |> latitude_t(Map.get(args, :latitude_t), setter)
      |> longitude_f(Map.get(args, :longitude_f), setter)
      |> longitude_t(Map.get(args, :longitude_t), setter)
      |> description(Map.get(args, :description), setter)
      |> is_active(Map.get(args, :is_active), setter)
      |> created_f(Map.get(args, :created_f), setter)
      |> created_t(Map.get(args, :created_t), setter)
  end

  def build(_) do
    {:error, "Невалидные данные для фильтра"}
  end

  defp filter do
    {:ok, %Filter{}}
  end

  defp ip({:ok, filter}, ip, setter) do
    case ip do
      nil -> {:ok, filter}
      ip -> BuilderProperties.build({:ok, filter}, Ip, setter, :ip, ip)
    end
  end

  defp ip({:error, message}, _, _) do
    {:error, message}
  end

  defp latitude_f({:ok, filter}, latitude_f, setter) do
    case latitude_f do
      nil -> {:ok, filter}
      latitude_f -> BuilderProperties.build({:ok, filter}, Latitude, setter, :latitude_f, latitude_f)
    end
  end

  defp latitude_f({:error, message}, _, _) do
    {:error, message}
  end

  defp latitude_t({:ok, filter}, latitude_t, setter) do
    case latitude_t do
      nil -> {:ok, filter}
      latitude_t -> BuilderProperties.build({:ok, filter}, Latitude, setter, :latitude_t, latitude_t)
    end
  end

  defp latitude_t({:error, message}, _, _) do
    {:error, message}
  end

  defp longitude_f({:ok, filter}, longitude_f, setter) do
    case longitude_f do
      nil -> {:ok, filter}
      longitude_f -> BuilderProperties.build({:ok, filter}, Longitude, setter, :longitude_f, longitude_f)
    end
  end

  defp longitude_f({:error, message}, _, _) do
    {:error, message}
  end

  defp longitude_t({:ok, filter}, longitude_t, setter) do
    case longitude_t do
      nil -> {:ok, filter}
      longitude_t -> BuilderProperties.build({:ok, filter}, Longitude, setter, :longitude_t, longitude_t)
    end
  end

  defp longitude_t({:error, message}, _, _) do
    {:error, message}
  end

  defp description({:ok, filter}, description, setter) do
    case description do
      nil -> {:ok, filter}
      description -> BuilderProperties.build({:ok, filter}, Description, setter, :desc, description)
    end
  end

  defp description({:error, message}, _, _) do
    {:error, message}
  end

  defp is_active({:ok, filter}, is_active, setter) do
    case is_active do
      nil -> {:ok, filter}
      is_active -> BuilderProperties.build({:ok, filter}, Boolean, setter, :is_active, is_active)
    end
  end

  defp is_active({:error, message}, _, _) do
    {:error, message}
  end

  defp created_f({:ok, filter}, created_f, setter) do
    case created_f do
      nil -> {:ok, filter}
      created_f -> BuilderProperties.build({:ok, filter}, Date, setter, :created_f, created_f)
    end
  end

  defp created_f({:error, message}, _, _) do
    {:error, message}
  end

  defp created_t({:ok, filter}, created_t, setter) do
    case created_t do
      nil -> {:ok, filter}
      created_t -> BuilderProperties.build({:ok, filter}, Date, setter, :created_t, created_t)
    end
  end

  defp created_t({:error, message}, _, _) do
    {:error, message}
  end
end