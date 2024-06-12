defmodule Core.Device.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Device.Entity

  alias Core.Shared.Builders.BuilderProperties
  
  alias Core.Device.Validators.Ip
  alias Core.Device.Validators.Latitude
  alias Core.Device.Validators.Longitude
  alias Core.Device.Validators.Description
  alias Core.Device.Validators.Group
  alias Core.Shared.Validators.Boolean

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    setter = fn (
      entity, 
      key, 
      value
    ) -> 
      Map.put(entity, key, value) 
    end

    entity(entity)
      |> ip(Map.get(args, :ip), setter)
      |> longitude(Map.get(args, :longitude), setter)
      |> latitude(Map.get(args, :latitude), setter)
      |> desc(Map.get(args, :desc), setter)
      |> group(Map.get(args, :group), setter)
      |> is_active(Map.get(args, :is_active), setter)
  end

  def edit(_, _) do
    {:error, "Невалидные данные для редактирования устройства"}
  end

  defp entity(%Entity{} = entity) do
    {:ok, %Entity{
      id: entity.id, 
      ip: entity.ip,
      latitude: entity.latitude,
      longitude: entity.longitude,
      desc: entity.desc,
      group: entity.group,
      is_active: entity.is_active,
      created: entity.created, 
      updated: Date.utc_today
    }}
  end

  defp ip({:ok, entity}, ip, setter) do
    case ip do
      nil -> {:ok, entity}
      ip -> BuilderProperties.build({:ok, entity}, Ip, setter, :ip, ip)
    end
  end

  defp ip({:error, message}, _, _) do
    {:error, message}
  end

  defp latitude({:ok, entity}, latitude, setter) do
    case latitude do
      nil -> {:ok, entity}
      latitude -> BuilderProperties.build({:ok, entity}, Latitude, setter, :latitude, latitude)
    end
  end

  defp latitude({:error, message}, _, _) do
    {:error, message}
  end

  defp longitude({:ok, entity}, longitude, setter) do
    case longitude do
      nil -> {:ok, entity}
      longitude -> BuilderProperties.build({:ok, entity}, Longitude, setter, :longitude, longitude)
    end
  end

  defp longitude({:error, message}, _, _) do
    {:error, message}
  end

  defp desc({:ok, entity}, desc, setter) do
    case desc do
      nil -> {:ok, entity}
      desc -> BuilderProperties.build({:ok, entity}, Description, setter, :desc, desc)
    end
  end

  defp desc({:error, message}, _, _) do
    {:error, message}
  end

  defp group({:ok, entity}, group, setter) do
    case group do
      nil -> {:ok, entity}
      group -> BuilderProperties.build({:ok, entity}, Group, setter, :group, group)
    end
  end

  defp group({:error, message}, _, _) do
    {:error, message}
  end

  defp is_active({:ok, entity}, is_active, setter) do
    case is_active do
      nil -> {:ok, entity}
      is_active -> BuilderProperties.build({:ok, entity}, Boolean, setter, :is_active, is_active)
    end
  end

  defp is_active({:error, message}, _, _) do
    {:error, message}
  end
end