defmodule Core.Device.Editor do
  @moduledoc """
    Редактор сущности
  """

  alias Core.Shared.Types.Success
  alias Core.Shared.Types.Error
  alias Core.Device.Entity
  
  alias Core.Device.Builders.Ip
  alias Core.Device.Builders.Latitude
  alias Core.Device.Builders.Longitude
  alias Core.Device.Builders.Description
  alias Core.Device.Builders.Group

  @spec edit(Entity.t(), map()) :: Success.t() | Error.t()
  def edit(%Entity{} = entity, args) when is_map(args) do
    entity(entity)
      |> ip(Map.get(args, :ip))
      |> longitude(Map.get(args, :longitude))
      |> latitude(Map.get(args, :latitude))
      |> desc(Map.get(args, :desc))
      |> group(Map.get(args, :group))
      |> is_active(Map.get(args, :is_active))
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

  defp ip({:ok, entity}, ip) do
    case ip do
      nil -> {:ok, entity}
      ip -> Ip.build({:ok, entity}, ip)
    end
  end

  defp ip({:error, message}, _) do
    {:error, message}
  end

  defp latitude({:ok, entity}, latitude) do
    case latitude do
      nil -> {:ok, entity}
      latitude -> Latitude.build({:ok, entity}, latitude)
    end
  end

  defp latitude({:error, message}, _) do
    {:error, message}
  end

  defp longitude({:ok, entity}, longitude) do
    case longitude do
      nil -> {:ok, entity}
      longitude -> Longitude.build({:ok, entity}, longitude)
    end
  end

  defp longitude({:error, message}, _) do
    {:error, message}
  end

  defp desc({:ok, entity}, desc) do
    case desc do
      nil -> {:ok, entity}
      desc -> Description.build({:ok, entity}, desc)
    end
  end

  defp desc({:error, message}, _) do
    {:error, message}
  end

  defp group({:ok, entity}, group) do
    case group do
      nil -> {:ok, entity}
      group -> Group.build({:ok, entity}, group)
    end
  end

  defp group({:error, message}, _) do
    {:error, message}
  end

  defp is_active({:ok, entity}, is_active) do
    with false <- is_active == nil,
         true <- is_boolean(is_active) do
      {:ok, Map.put(entity, :is_active, is_active)}
    else
      true -> {:ok, entity}
      false -> {:error, "Не валидная активность"}
    end
  end

  defp is_active({:error, message}, _) do
    {:error, message}
  end
end