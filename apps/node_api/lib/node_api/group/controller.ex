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

  def create(conn) do
    args = %{
      name: Map.get(conn.body_params, "name"),
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById
    adapter_1 = GroupInserting

    try do
      case Creating.create(adapter_0, adapter_1, args) do
        {:ok, true} -> 
          NodeApi.Logger.info("Создана группа устройств")

          json = Jason.encode!(true)

          conn |> Plug.Conn.send_resp(200, json)

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

    adapter_0 = UserGettingById
    adapter_1 = GroupGettingById
    adapter_2 = GroupUpdating

    try do
      case Updating.update(adapter_0, adapter_1, adapter_2, args) do
        {:ok, true} -> 
          NodeApi.Logger.info("Обновлена группа устройств")

          json = Jason.encode!(true)

          conn |> Plug.Conn.send_resp(200, json)

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

    adapter_0 = UserGettingById
    adapter_1 = GroupGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          NodeApi.Logger.info("Получен список групп устройств")

          fun = fn (group) -> 
            %{
              id: group.id,
              name: group.name,
              sum: group.sum,
              created: group.created
            }
          end

          json = Jason.encode!(Enum.map(list, fun))

          conn |> Plug.Conn.send_resp(200, json)

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

    adapter_0 = UserGettingById
    adapter_1 = GroupGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, group} -> 
          NodeApi.Logger.info("Получена группа устройств")
          
          fun = fn (device) -> 
            %{
              id: device.id,
              ip: device.ip,
              latitude: device.latitude,
              longitude: device.longitude,
              desc: device.desc,
              is_active: device.is_active,
              created: device.created,
            }
          end

          json = Jason.encode!(%{
            id: group.id,
            name: group.name,
            sum: group.sum,
            created: group.created,
            updated: group.created,
            devices: Enum.map(group.devices, fun)
          })

          conn |> Plug.Conn.send_resp(200, json)

        {:error, message} -> NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end