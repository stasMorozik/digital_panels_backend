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

  def create(conn) do
    args = %{
      file_id: Map.get(conn.body_params, "file_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      serial_number: NodeApi.Utils.Parsers.Integer.parse(conn.body_params, "serial_number"),
      duration: NodeApi.Utils.Parsers.Integer.parse(conn.body_params, "duration"),
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById
    adapter_1 = PlaylistGettingById
    adapter_2 = FileGettingById
    adapter_3 = ContentInserting

    try do
      case Creating.create(adapter_0, adapter_1, adapter_2, adapter_3, args) do
        {:ok, true} -> 
          message = "Создан контен"
          payload = true

          NodeApi.Notifiers.Node.notify(%{playlist_id: args.playlist_id})
          
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
      file_id: Map.get(conn.body_params, "file_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      serial_number: NodeApi.Utils.Parsers.Integer.parse(conn.body_params, "serial_number"),
      duration: NodeApi.Utils.Parsers.Integer.parse(conn.body_params, "duration"),
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
          message = "Обновлен контен"
          payload = true

          NodeApi.Notifiers.Node.notify(%{playlist_id: args.playlist_id})

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
        page: NodeApi.Utils.Parsers.Integer.parse(pagi, "page"),
        limit: NodeApi.Utils.Parsers.Integer.parse(pagi, "limit"),
      },
      filter: %{
        name: Map.get(filter, "name"),
        duration_f: NodeApi.Utils.Parsers.Integer.parse(filter, "duration_f"),
        duration_t: NodeApi.Utils.Parsers.Integer.parse(filter, "duration_t"),
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
          message = "Получен список контента"
          payload = Enum.map(list, fun = fn (content) -> %{
            id: content.id,
            name: content.name,
            duration: content.duration,
            created: content.created,
            updated: content.updated
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
    adapter_1 = ContentGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, content} -> 
          message = "Получен контент"
          payload = %{
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
              playlist: %{
                id: content.playlist.id,
                name: content.playlist.name,
                created: content.playlist.created,
                updated: content.playlist.updated
              },
              serial_number: content.serial_number,
              created: content.created,
              updated: content.updated
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