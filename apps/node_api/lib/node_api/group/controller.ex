defmodule NodeApi.Group.Controller do

  alias Core.Group.UseCases.Creating
  alias Core.Group.UseCases.Updating
  alias Core.Group.UseCases.Getting
  alias Core.Group.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Group.Inserting, as: GroupInserting
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById
  alias PostgresqlAdapters.Group.Updating, as: GroupUpdating
  alias PostgresqlAdapters.Group.GettingList, as: GroupGettingList

  @name_node Application.compile_env(:node_api, :name_node)

  def create(conn) do
    args = %{
      name: Map.get(conn.body_params, "name"),
      token: Map.get(conn.cookies, "access_token")
    }

    try do
      case Creating.create(UserGettingById, GroupInserting, args) do
        {:ok, true} -> 
          ModLogger.Logger.info(%{
            message: "Создана группа устройств", 
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
      name: Map.get(conn.body_params, "name"),
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    try do
      case Updating.update(UserGettingById, GroupGettingById, GroupUpdating, args) do
        {:ok, true} -> 
          ModLogger.Logger.info(%{
            message: "Обновлена группа устройств", 
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
        name: Map.get(filter, "name"), 
        sum_f: NodeApi.Utils.integer_parse(filter, "sum_f"), 
        sum_t: NodeApi.Utils.integer_parse(filter, "sum_t"), 
        created_f: Map.get(filter, "created_f"), 
        created_t: Map.get(filter, "created_t")
      },
      sort: %{
        name: Map.get(sort, "name"), 
        sum: Map.get(sort, "sum"), 
        created: Map.get(sort, "created")
      }
    }

    try do
      case GettingList.get(UserGettingById, GroupGettingList, args) do
        {:ok, list} -> 
          ModLogger.Logger.info(%{
            message: "Получен список групп устройств", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(
            Enum.map(list, fn (group) -> 
              %{
                id: group.id,
                name: group.name,
                sum: group.sum,
                created: group.created
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
      case Getting.get(UserGettingById, GroupGettingById, args) do
        {:ok, group} -> 
          ModLogger.Logger.info(%{
            message: "Получена группа устройств",
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(%{
            id: group.id,
            name: group.name,
            sum: group.sum,
            created: group.created,
            updated: group.created,
            devices: Enum.map(group.devices, fn (device) -> 
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
          }))

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end