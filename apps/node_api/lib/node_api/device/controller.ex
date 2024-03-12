defmodule NodeApi.Device.Controller do

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

  @name_node Application.compile_env(:node_api, :name_node)

  def create(conn) do
    args = %{
      ip: Map.get(conn.body_params, "ip"), 
      latitude: NodeApi.Utils.float_parse(conn.body_params, "latitude"), 
      longitude: NodeApi.Utils.float_parse(conn.body_params, "longitude"),
      desc: Map.get(conn.body_params, "desc"),
      group_id: Map.get(conn.body_params, "group_id"),
      is_active: Map.get(conn.body_params, "is_active"),
      token: Map.get(conn.cookies, "access_token")
    }

    try do
      case Creating.create(UserGettingById, GroupGettingById, DeviceInserting, args) do
        {:ok, true} -> 
          ModLogger.Logger.info(%{
            message: "Создано устройство", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(true))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end

  def update(conn, id) do
    args = %{
      ip: Map.get(conn.body_params, "ip"), 
      latitude: NodeApi.Utils.float_parse(conn.body_params, "latitude"), 
      longitude: NodeApi.Utils.float_parse(conn.body_params, "longitude"),
      desc: Map.get(conn.body_params, "desc"),
      is_active: Map.get(conn.body_params, "is_active"),
      group_id: Map.get(conn.body_params, "group_id"),
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    try do
      case Updating.update(
        UserGettingById, 
        GroupGettingById, 
        DeviceGettingById, 
        DeviceUpdating, 
        args
      ) do
        {:ok, true} -> 
          ModLogger.Logger.info(%{
            message: "Обновлено устройство", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(true))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
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
        latitude_f: NodeApi.Utils.float_parse(filter, "latitude_f"),
        latitude_t: NodeApi.Utils.float_parse(filter, "latitude_t"),
        longitude_f: NodeApi.Utils.float_parse(filter, "longitude_f"),
        longitude_t: NodeApi.Utils.float_parse(filter, "longitude_t"),
        description: Map.get(filter, "description"),
        is_active: NodeApi.Utils.boolen_parse(filter, "is_active"),
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

    try do
      case GettingList.get(UserGettingById, DeviceGettingList, args) do
        {:ok, list} -> 
          ModLogger.Logger.info(%{
            message: "Получен список устройств", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(
            Enum.map(list, fn (device) -> 
              %{
                id: device.id, 
                ip: device.ip, 
                latitude: device.latitude, 
                longitude: device.longitude, 
                desc: device.desc,
                is_active: device.is_active,
                created: device.created, 
              }
            end)
          ))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end

  def get(conn, id) do
    args = %{
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    try do
      case Getting.get(UserGettingById, DeviceGettingById, args) do
        {:ok, device} -> 
          ModLogger.Logger.info(%{
            message: "Получено устройство", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(%{
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
          }))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end