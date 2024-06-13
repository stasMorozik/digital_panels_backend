defmodule NodeApi.Controllers.Content do

  alias Core.Content.UseCases.Creating
  alias Core.Content.UseCases.Updating
  alias Core.Content.UseCases.Getting
  alias Core.Content.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Content.Inserting, as: ContentInserting
  alias PostgresqlAdapters.Content.GettingById, as: ContentGettingById
  alias PostgresqlAdapters.Content.Updating, as: ContentUpdating
  alias PostgresqlAdapters.Content.GettingList, as: ContentGettingList
  alias PostgresqlAdapters.Playlist.GettingById, as: PlaylistGettingById
  alias PostgresqlAdapters.File.GettingById, as: FileGettingById

  alias NodeApi.Notifiers.Node
  alias NodeApi.Utils.Parsers.Integer
  alias NodeApi.Handlers.Success
  alias NodeApi.Handlers.Error
  alias NodeApi.Handlers.Exception
  alias NodeApi.Logger, as: AppLogger

  def create(conn) do
    args = %{
      file_id: Map.get(conn.body_params, "file_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      serial_number: Integer.parse(conn.body_params, "serial_number"),
      duration: Integer.parse(conn.body_params, "duration"),
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById
    adapter_1 = PlaylistGettingById
    adapter_2 = FileGettingById
    adapter_3 = ContentInserting

    try do
      case Creating.create(adapter_0, adapter_1, adapter_2, adapter_3, args) do
        {:ok, true} -> 
          AppLogger.info("Создан контен")

          Node.notify(%{playlist_id: args.playlist_id})

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
      file_id: Map.get(conn.body_params, "file_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      serial_number: Integer.parse(conn.body_params, "serial_number"),
      duration: Integer.parse(conn.body_params, "duration"),
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    adapter_0 = UserGettingById
    adapter_1 = PlaylistGettingById
    adapter_2 = ContentGettingById
    adapter_3 = FileGettingById
    adapter_4 = ContentUpdating

    try do
      case Updating.update(adapter_0, adapter_1, adapter_2, adapter_3, adapter_4, args) do
        {:ok, true} -> 
          AppLogger.info("Обновлен контен")

          Node.notify(%{playlist_id: args.playlist_id})

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
        duration_f: Integer.parse(filter, "duration_f"),
        duration_t: Integer.parse(filter, "duration_t"),
        created_f: Map.get(filter, "created_f"), 
        created_t: Map.get(filter, "created_t")
      },
      sort: %{
        name: Map.get(sort, "name"),
        duration: Map.get(sort, "duration"),
        created: Map.get(sort, "created")
      }
    }

    adapter_0 = UserGettingById
    adapter_1 = ContentGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          AppLogger.info("Получен список контента")

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
    adapter_1 = ContentGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, content} -> 
          AppLogger.info("Получен контент")

          Success.handle(conn, content)
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