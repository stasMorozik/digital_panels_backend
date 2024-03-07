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

    try do
      case Creating.create(UserGettingById, GroupInserting, args) do
        {:ok, true} -> 
          NodeApi.Logger.info("Созданна группа устройств")

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
          NodeApi.Logger.info("Обновлена группа устройств")

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
        page: case Map.get(pagi, "page") do
          nil -> nil
          page -> case Integer.parse(page) do
            :error -> nil
            {page, _} -> page 
          end
        end,
        limit: case Map.get(pagi, "limit") do
          nil -> nil
          limit -> case Integer.parse(limit) do
            :error -> nil
            {limit, _} -> limit 
          end
        end,
      },
      filter: %{
        name: Map.get(filter, "name"), 
        sum_f: case Map.get(pagi, "sum_f") do
          nil -> nil
          sum_f -> case Integer.parse(sum_f) do
            :error -> nil
            {sum_f, _} -> sum_f 
          end
        end, 
        sum_t: case Map.get(pagi, "sum_t") do
          nil -> nil
          sum_t -> case Integer.parse(sum_t) do
            :error -> nil
            {sum_t, _} -> sum_t 
          end
        end, 
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
          NodeApi.Logger.info("Получен список групп устройств")

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
          NodeApi.Logger.info("Получена группа устройств")

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