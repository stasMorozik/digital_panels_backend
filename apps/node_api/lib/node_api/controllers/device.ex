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
          message = "Создано устройство"
          payload = true

          NodeApi.Notifiers.Node.notify(%{group_id: args.group_id})

          NodeApi.Handlers.Success.handle(conn, payload, message)
        {:error, message} -> 
          NodeApi.Handlers.Error.handle(conn, message)
        {:exception, message} -> 
          NodeApi.Handlers.Exception.handle(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.Exception.handle(conn, Map.get(e.message))
    end
  end

  def update(conn, id) do
    args = %{
      ip: Map.get(conn.body_params, "ip"), 
      latitude: NodeApi.Utils.Parsers.Float.parse(conn.body_params, "latitude"), 
      longitude: NodeApi.Utils.Parsers.Float.parse(conn.body_params, "longitude"),
      desc: Map.get(conn.body_params, "desc"),
      is_active: NodeApi.Utils.Parsers.Boolen.parse(conn.body_params, "is_active"),
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
          message = "Обновлено устройство"
          payload = true

          NodeApi.Notifiers.Node.notify(%{group_id: args.group_id})

          NodeApi.Handlers.Success.handle(conn, payload, message)
        {:error, message} -> 
          NodeApi.Handlers.Error.handle(conn, message)
        {:exception, message} -> 
          NodeApi.Handlers.Exception.handle(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.Exception.handle(conn, Map.get(e.message))
    end
  end

  def list(conn) do
    filter = Map.get(conn.query_params, "filter", %{})
    sort = Map.get(conn.query_params, "sort", %{})
    pagi = Map.get(conn.query_params, "pagi", %{})

    args = %{
      token: Map.get(conn.cookies, "access_token"),
      pagi: %{
        page: NodeApi.Utils.integer_parse(pagi, "page"),
        limit: NodeApi.Utils.integer_parse(pagi, "limit"),
      },
      filter: %{
        ip: Map.get(filter, "ip"),
        latitude_f: NodeApi.Utils.Parsers.Float.parse(filter, "latitude_f"),
        latitude_t: NodeApi.Utils.Parsers.Float.parse(filter, "latitude_t"),
        longitude_f: NodeApi.Utils.Parsers.Float.parse(filter, "longitude_f"),
        longitude_t: NodeApi.Utils.Parsers.Float.parse(filter, "longitude_t"),
        description: Map.get(filter, "description"),
        is_active: NodeApi.Utils.Parsers.Boolen.parse(filter, "is_active"),
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
          message = "Получен список устройств"
          payload = Enum.map(list, fn (device) -> %{
            id: device.id, 
            ip: device.ip, 
            latitude: device.latitude, 
            longitude: device.longitude, 
            desc: device.desc,
            is_active: device.is_active,
            created: device.created, 
          } end)

          NodeApi.Handlers.Success.handle(conn, payload, message)
        {:error, message} -> 
          NodeApi.Handlers.Error.handle(conn, message)
        {:exception, message} -> 
          NodeApi.Handlers.Exception.handle(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.Exception.handle(conn, Map.get(e.message))
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
          message = "Получено устройство"
          payload = %{
            id: device.id, 
            ip: device.ip, 
            latitude: device.latitude, 
            longitude: device.longitude, 
            desc: device.desc,
            is_active: device.is_active,
            created: device.created,
            updated: device.updated,
            group: %{
              id: device.group.id, 
              name: device.group.name,
              sum: device.group.sum,
              created: device.group.created, 
              updated: device.group.updated
            } 
          }

          NodeApi.Handlers.Success.handle(conn, payload, message)
        {:error, message} -> 
          NodeApi.Handlers.Error.handle(conn, message)
        {:exception, message} -> 
          NodeApi.Handlers.Exception.handle(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.Exception.handle(conn, Map.get(e.message))
    end
  end
end