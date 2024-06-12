defmodule NodeApi.Controllers.Playlist do

  alias Core.Playlist.UseCases.Creating
  alias Core.Playlist.UseCases.Updating
  alias Core.Playlist.UseCases.Getting
  alias Core.Playlist.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Playlist.Inserting, as: PlaylistInserting
  alias PostgresqlAdapters.Playlist.GettingById, as: PlaylistGettingById
  alias PostgresqlAdapters.Playlist.Updating, as: PlaylistUpdating
  alias PostgresqlAdapters.Playlist.GettingList, as: PlaylistGettingList

  def create(conn) do
    args = %{
      name: Map.get(conn.body_params, "name"),
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById
    adapter_1 = PlaylistInserting

    try do
      case Creating.create(adapter_0, adapter_1, args) do
        {:ok, true} -> 
          message = "Создан плэйлист"
          payload = true

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
      name: Map.get(conn.body_params, "name"),
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    adapter_0 = UserGettingById
    adapter_1 = PlaylistGettingById
    adapter_2 = PlaylistUpdating

    try do
      case Updating.update(adapter_0, adapter_1, adapter_2, args) do
        {:ok, true} -> 
          message = "Обновлен плэйлист"
          payload = true

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
        sum_f: NodeApi.Utils.Parsers.Integer.parse(filter, "sum_f"), 
        sum_t: NodeApi.Utils.Parsers.Integer.parse(filter, "sum_t"), 
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
    adapter_1 = PlaylistGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          message = "Получен список плэйлистов"
          payload = Enum.map(list, fn (playlist) -> %{
            id: playlist.id,
            name: playlist.name,
            sum: playlist.sum,
            created: playlist.created
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
    adapter_1 = PlaylistGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, playlist} -> 
          message = "Получен плэйлист"
          payload = %{
            id: playlist.id,
            name: playlist.name,
            sum: playlist.sum,
            created: playlist.created,
            updated: playlist.created,
            contents: Enum.map(playlist.contents, fn (content) -> %{
              id: content.id,
              name: content.name,
              duration: content.duration,
              file: %{
                id: content.file.id, 
                path: content.file.path, 
                url: content.file.url, 
                extension: content.file.extension, 
                type: content.file.type, 
                size: content.file.size, 
                created: content.file.created
              },
              serial_number: content.serial_number,
              created: content.created,
              updated: content.updated
            } end)
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