defmodule NodeApi.Content.Controller do

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
      serial_number: NodeApi.Utils.integer_parse(conn.body_params, "serial_number"),
      duration: NodeApi.Utils.integer_parse(conn.body_params, "duration"),
      token: Map.get(conn.cookies, "access_token")
    }

    try do
      case Creating.create(
        UserGettingById, 
        PlaylistGettingById, 
        FileGettingById, 
        ContentInserting, 
        args
      ) do
        {:ok, true} -> 
          NodeApi.Logger.info("Создан контент")

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
      file_id: Map.get(conn.body_params, "file_id"),
      playlist_id: Map.get(conn.body_params, "playlist_id"),
      name: Map.get(conn.body_params, "name"),
      serial_number: NodeApi.Utils.integer_parse(conn.body_params, "serial_number"),
      duration: NodeApi.Utils.integer_parse(conn.body_params, "duration"),
      token: Map.get(conn.cookies, "access_token"),
      id: id
    }

    try do
      case Updating.update(
        UserGettingById, 
        PlaylistGettingById, 
        ContentGettingById,
        FileGettingById,
        ContentUpdating, 
        args
      ) do
        {:ok, true} -> 
          NodeApi.Logger.info("Обновлено устройство")

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
        duration_f: NodeApi.Utils.integer_parse(filter, "duration_f"),
        duration_t: NodeApi.Utils.integer_parse(filter, "duration_t"),
        created_f: Map.get(filter, "created_f"), 
        created_t: Map.get(filter, "created_t")
      },
      sort: %{
        name: Map.get(sort, "name"),
        duration: Map.get(sort, "duration"),
        created: Map.get(sort, "created")
      }
    }

    try do
      case GettingList.get(UserGettingById, ContentGettingList, args) do
        {:ok, list} -> 
          NodeApi.Logger.info("Получен список контента")

          conn |> Plug.Conn.send_resp(200, Jason.encode!(
            Enum.map(list, fn (content) -> 
              %{
                id: content.id,
                name: content.name,
                duration: content.duration,
                created: content.created,
                updated: content.updated
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

    try do
      case Getting.get(UserGettingById, ContentGettingById, args) do
        {:ok, content} -> 
          NodeApi.Logger.info("Получен контент")

          conn |> Plug.Conn.send_resp(200, Jason.encode!(%{
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