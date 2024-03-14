defmodule NodeApi.Task.Controller do

  alias Core.Task.UseCases.Creating
  alias Core.Task.UseCases.Updating
  alias Core.Task.UseCases.Getting
  alias Core.Task.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Task.Inserting, as: TaskInserting
  alias PostgresqlAdapters.Task.GettingById, as: TaskGettingById
  alias PostgresqlAdapters.Task.Updating, as: TaskUpdating
  alias PostgresqlAdapters.Task.GettingList, as: TaskGettingList
  alias PostgresqlAdapters.Playlist.GettingById, as: PlaylistGettingById
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById

  @name_node Application.compile_env(:node_api, :name_node)

  def create(conn) do
    args = %{
      group_id: Map.get(conn.body_params, "group_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      type: Map.get(conn.body_params, "type"),
      day: NodeApi.Utils.integer_parse(conn.body_params, "day"),
      start_hour: NodeApi.Utils.integer_parse(conn.body_params, "start_hour"),
      end_hour: NodeApi.Utils.integer_parse(conn.body_params, "end_hour"),
      start_minute: NodeApi.Utils.integer_parse(conn.body_params, "start_minute"),
      end_minute: NodeApi.Utils.integer_parse(conn.body_params, "end_minute"),
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById
    adapter_1 = PlaylistGettingById
    adapter_2 = GroupGettingById
    adapter_3 = TaskGettingList
    adapter_4 = TaskInserting

    try do
      case Creating.create(adapter_0, adapter_1, adapter_2, adapter_3, adapter_4, args) do
        {:ok, true} -> 
          ModLogger.Logger.info(%{
            message: "Создано задание",
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(true))

        {:error, message} -> 
          NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> 
          NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end

  def update(conn, id) do
    args = %{
      group_id: Map.get(conn.body_params, "group_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      type: Map.get(conn.body_params, "type"),
      day: NodeApi.Utils.integer_parse(conn.body_params, "day"),
      start_hour: NodeApi.Utils.integer_parse(conn.body_params, "start_hour"),
      end_hour: NodeApi.Utils.integer_parse(conn.body_params, "end_hour"),
      start_minute: NodeApi.Utils.integer_parse(conn.body_params, "start_minute"),
      end_minute: NodeApi.Utils.integer_parse(conn.body_params, "end_minute"),
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    adapter_0 = UserGettingById
    adapter_1 = PlaylistGettingById
    adapter_2 = GroupGettingById
    adapter_3 = TaskGettingById
    adapter_4 = TaskGettingList
    adapter_5 = TaskUpdating

    try do
      case Updating.update(adapter_0, adapter_1, adapter_2, adapter_3, adapter_4, adapter_5, args) do
        {:ok, true} -> 
          ModLogger.Logger.info(%{
            message: "Обновлено задание", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(true))

        {:error, message} -> 
          NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> 
          NodeApi.Handlers.handle_exception(conn, message)
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
        type: Map.get(filter, "type"),
        group: Map.get(filter, "group"),
        day: NodeApi.Utils.integer_parse(filter, "day"),
        start_hour: NodeApi.Utils.integer_parse(filter, "start_hour"),
        start_minute: NodeApi.Utils.integer_parse(filter, "start_minute"),
        end_hour: NodeApi.Utils.integer_parse(filter, "end_hour"),
        end_minute: NodeApi.Utils.integer_parse(filter, "end_minute"),
        created_f: Map.get(filter, "created_f"), 
        created_t: Map.get(filter, "created_t")
      },
      sort: %{
        name: Map.get(sort, "name"),
        type: Map.get(sort, "type"),
        created: Map.get(sort, "created")
      }
    }

    adapter_0 = UserGettingById
    adapter_1 = TaskGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          ModLogger.Logger.info(%{
            message: "Получен список заданий", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(
            Enum.map(list, fn (task) -> 
              %{
                id: task.id,
                name: task.name,
                type: task.type,
                day: task.day,
                start_hour: task.start_hour,
                end_hour: task.end_hour,
                start_minute: task.start_minute,
                end_minute: task.end_minute,
                start: task.start,
                end: task.end,
                created: task.created,
                group: %{
                  id: task.group.id,
                  name: task.group.name
                },
              }
            end)
          ))

        {:error, message} -> 
          NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> 
          NodeApi.Handlers.handle_exception(conn, message)
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
    adapter_1 = TaskGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, task} -> 
          ModLogger.Logger.info(%{
            message: "Получено задание", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(%{
              id: task.id,
              name: task.name,
              type: task.type,
              day: task.day,
              start_hour: task.start_hour,
              end_hour: task.end_hour,
              start_minute: task.start_minute,
              end_minute: task.end_minute,
              start: task.start,
              end: task.end,
              sum: task.sum,
              created: task.created,
              updated: task.updated,
              playlist: %{
                id: task.playlist.id, 
                name: task.playlist.name,
                sum: task.playlist.sum,
                contents: Enum.map(task.playlist.contents, fn (content) -> 
                  %{
                    id: content.id,
                    name: content.name,
                    duration: content.duration,
                    file: %{
                      id: content.file.id, 
                      url: content.file.url, 
                      extension: content.file.extension, 
                      type: content.file.type, 
                      size: content.file.size, 
                      created: content.file.created
                    },
                    serial_number: content.serial_number,
                    created: content.created,
                    updated: content.updated
                  }
                end),
                created: task.created,
                updated: task.updated
              },
              group: %{
                id: task.group.id,
                name: task.group.name,
                created: task.group.created, 
                updated: task.group.updated
              },
          }))

        {:error, message} -> 
          NodeApi.Handlers.handle_error(conn, message, 400)

        {:exception, message} -> 
          NodeApi.Handlers.handle_exception(conn, message)
      end
    rescue
      e -> NodeApi.Handlers.handle_exception(conn, e)
    end
  end
end