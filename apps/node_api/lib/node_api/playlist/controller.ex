defmodule NodeApi.Playlist.Controller do

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
          NodeApi.Logger.info("Создан плэйлист")

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
    adapter_1 = PlaylistGettingById
    adapter_2 = PlaylistUpdating

    try do
      case Updating.update(adapter_0, adapter_1, adapter_2, args) do
        {:ok, true} -> 
          NodeApi.Logger.info("Обновлен плэйлист")

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
    adapter_1 = PlaylistGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          NodeApi.Logger.info("Получен список плэйлистов")

          fun = fn (playlist) -> 
            %{
              id: playlist.id,
              name: playlist.name,
              sum: playlist.sum,
              created: playlist.created
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
    adapter_1 = PlaylistGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, playlist} -> 
          NodeApi.Logger.info("Получен плэйлист")
          
          fun = fn (content) -> 
            %{
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
            }
          end

          json = Jason.encode!(%{
            id: playlist.id,
            name: playlist.name,
            sum: playlist.sum,
            created: playlist.created,
            updated: playlist.created,
            contents: Enum.map(playlist.contents, fun)
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