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

  alias NodeApi.Handlers.Success
  alias NodeApi.Handlers.Error
  alias NodeApi.Handlers.Exception
  alias NodeApi.Utils.Parsers.Integer
  alias NodeApi.Logger, as: AppLogger

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
          AppLogger.info("Создан плэйлист")

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
          AppLogger.info("Обновлен плэйлист")

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
        sum_f: Integer.parse(filter, "sum_f"), 
        sum_t: Integer.parse(filter, "sum_t"), 
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
          AppLogger.info("Получен список плэйлистов")

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
    adapter_1 = PlaylistGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, playlist} -> 
          AppLogger.info("Получен плэйлист")

          Success.handle(conn, playlist)
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