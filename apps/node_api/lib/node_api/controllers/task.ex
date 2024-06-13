defmodule NodeApi.Controllers.Task do

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
  
  alias NodeApi.Utils.Parsers.Integer
  alias NodeApi.Notifiers.Node
  alias NodeApi.Handlers.Success
  alias NodeApi.Handlers.Error
  alias NodeApi.Handlers.Exception
  alias NodeApi.Logger, as: AppLogger

  def create(conn) do
    args = %{
      group_id: Map.get(conn.body_params, "group_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      type: Map.get(conn.body_params, "type"),
      day: Integer.parse(conn.body_params, "day"),
      start_hour: Integer.parse(conn.body_params, "start_hour"),
      end_hour: Integer.parse(conn.body_params, "end_hour"),
      start_minute: Integer.parse(conn.body_params, "start_minute"),
      end_minute: Integer.parse(conn.body_params, "end_minute"),
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
          AppLogger.info("Создано задание")

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
      group_id: Map.get(conn.body_params, "group_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      type: Map.get(conn.body_params, "type"),
      day: Integer.parse(conn.body_params, "day"),
      start_hour: Integer.parse(conn.body_params, "start_hour"),
      end_hour: Integer.parse(conn.body_params, "end_hour"),
      start_minute: Integer.parse(conn.body_params, "start_minute"),
      end_minute: Integer.parse(conn.body_params, "end_minute"),
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
          AppLogger.info("Обновлено задание")

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
        name: Map.get(filter, "name"),
        type: Map.get(filter, "type"),
        group: Map.get(filter, "group"),
        day: Integer.parse(filter, "day"),
        start_hour: Integer.parse(filter, "start_hour"),
        start_minute: Integer.parse(filter, "start_minute"),
        end_hour: Integer.parse(filter, "end_hour"),
        end_minute: Integer.parse(filter, "end_minute"),
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
          AppLogger.info("Получен список заданий")

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
    adapter_1 = TaskGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, task} -> 
          AppLogger.info("Получено задание")

          Success.handle(conn, task)
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