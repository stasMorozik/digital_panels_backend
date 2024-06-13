defmodule NodeApi.Controllers.Device do

  alias Core.Device.UseCases.Creating
  alias Core.Device.UseCases.Updating
  alias Core.Device.UseCases.Getting
  alias Core.Device.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Device.Inserting, as: DeviceInserting
  alias PostgresqlAdapters.Device.GettingById, as: DeviceGettingById
  alias PostgresqlAdapters.Device.Updating, as: DeviceUpdating
  alias PostgresqlAdapters.Device.GettingList, as: DeviceGettingList
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById

  alias NodeApi.Utils.Parsers.Float
  alias NodeApi.Utils.Parsers.Boolean
  alias NodeApi.Utils.Parsers.Integer

  alias NodeApi.Notifiers.Node

  alias NodeApi.Handlers.Success
  alias NodeApi.Handlers.Error
  alias NodeApi.Handlers.Exception
  alias NodeApi.Logger, as: AppLogger

  def create(conn) do
    args = %{
      ip: Map.get(conn.body_params, "ip"), 
      latitude: NodeApi.Utils.Parsers.Float.parse(conn.body_params, "latitude"), 
      longitude: NodeApi.Utils.Parsers.Float.parse(conn.body_params, "longitude"),
      desc: Map.get(conn.body_params, "desc"),
      group_id: Map.get(conn.body_params, "group_id"),
      is_active: Map.get(conn.body_params, "is_active"),
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById
    adapter_1 = GroupGettingById
    adapter_2 = DeviceInserting

    try do
      case Creating.create(adapter_0, adapter_1, adapter_2, args) do
        {:ok, true} -> 
          AppLogger.info("Создано устройство")

          Node.notify(%{group_id: args.group_id})

          Success.handle(conn, true)
        {:error, message} -> 
          Error.handle(conn, message)
        {:exception, message} -> 
          Exception.handle(conn, message)
      end
    rescue
      e -> Exception.handle(conn, Map.get(e, :message))
    end
  end

  def update(conn, id) do
    args = %{
      ip: Map.get(conn.body_params, "ip"), 
      latitude: Float.parse(conn.body_params, "latitude"), 
      longitude: Float.parse(conn.body_params, "longitude"),
      desc: Map.get(conn.body_params, "desc"),
      is_active: Boolean.parse(conn.body_params, "is_active"),
      group_id: Map.get(conn.body_params, "group_id"),
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    adapter_0 = UserGettingById
    adapter_1 = GroupGettingById
    adapter_2 = DeviceGettingById
    adapter_3 = DeviceUpdating

    try do
      case Updating.update(adapter_0, adapter_1, adapter_2, adapter_3, args) do
        {:ok, true} -> 
          AppLogger.info("Обновлено устройство")

          Node.notify(%{group_id: args.group_id})

          Success.handle(conn, true)
        {:error, message} -> 
          Error.handle(conn, message)
        {:exception, message} -> 
          Exception.handle(conn, message)
      end
    rescue
      e -> Exception.handle(conn, Map.get(e, :message))
    end
  end

  def list(conn) do
    filter = Map.get(conn.query_params, "filter", %{})
    sort = Map.get(conn.query_params, "sort", %{})
    pagi = Map.get(conn.query_params, "pagi", %{})

    args = %{
      token: Map.get(conn.cookies, "access_token"),
      pagi: %{
        page: Integer.parse(pagi, "page"),
        limit: Integer.parse(pagi, "limit"),
      },
      filter: %{
        ip: Map.get(filter, "ip"),
        latitude_f: Float.parse(filter, "latitude_f"),
        latitude_t: Float.parse(filter, "latitude_t"),
        longitude_f: Float.parse(filter, "longitude_f"),
        longitude_t: Float.parse(filter, "longitude_t"),
        description: Map.get(filter, "description"),
        is_active: Boolean.parse(filter, "is_active"),
        created_f: Map.get(filter, "created_f"),
        created_t: Map.get(filter, "created_t")
      },
      sort: %{
        ip: Map.get(sort, "ip"), 
        latitude: Map.get(sort, "latitude"), 
        longitude: Map.get(sort, "longitude"),
        is_active: Map.get(sort, "is_active"),
        created: Map.get(sort, "created")
      }
    }

    adapter_0 = UserGettingById
    adapter_1 = DeviceGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          AppLogger.info("Получен список устройств")

          Success.handle(conn, list)
        {:error, message} -> 
          Error.handle(conn, message)
        {:exception, message} -> 
          Exception.handle(conn, message)
      end
    rescue
      e -> Exception.handle(conn, Map.get(e, :message))
    end
  end

  def get(conn, id) do
    args = %{
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    adapter_0 = UserGettingById
    adapter_1 = DeviceGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, device} -> 
          AppLogger.info("Получено устройство")

          Success.handle(conn, device)
        {:error, message} -> 
          Error.handle(conn, message)
        {:exception, message} -> 
          Exception.handle(conn, message)
      end
    rescue
      e -> Exception.handle(conn, Map.get(e, :message))
    end
  end
end