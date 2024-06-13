defmodule NodeApi.Controllers.File do

  alias Core.File.UseCases.Creating
  alias Core.File.UseCases.Getting
  alias Core.File.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.File.Inserting, as: FileInserting
  alias HttpAdapters.File.Uploading, as: FileUploading
  alias PostgresqlAdapters.File.GettingById, as: FileGettingById
  alias PostgresqlAdapters.File.GettingList, as: FileGettingList

  alias NodeApi.Utils.Parsers.Integer
  alias NodeApi.Handlers.Success
  alias NodeApi.Handlers.Error
  alias NodeApi.Handlers.Exception
  alias NodeApi.Logger, as: AppLogger

  def create(conn) do
    try do
      with file <- Map.get(conn.body_params, "file"),
           false <- file == nil,
           args <- %{},
           args <- Map.put(args, :name, file.filename),
           args <- Map.put(args, :path, file.path),
           args <- Map.put(args, :extname, Path.extname(file.filename)),
           args <- Map.put(args, :size, FileSize.from_file(file.path)),
           args <- Map.put(args, :token, Map.get(conn.cookies, "access_token")),
           adapter_0 <- UserGettingById,
           adapter_1 <- FileInserting,
           adapter_2 <- FileUploading,
           {:ok ,true} <- Creating.create(adapter_0, adapter_1, adapter_2, args) do
        AppLogger.info("Создан файл")

        Success.handle(conn, true)
      else
        true ->
          Error.handle(conn, "Нет файла для загрузки")
        {:error, message} -> 
          Error.handle(conn, message)
        {:exception, message} -> 
          Exception.handle(conn, message)
      end
    rescue
      e -> 
        IO.inspect(e)
        Exception.handle(conn, Map.get(e, :message))
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
        type: Map.get(filter, "type"),
        url: Map.get(filter, "url"),
        extension: Map.get(filter, "extension"), 
        size: Integer.parse(filter, "size"),
        created_f: Map.get(filter, "created_f"), 
        created_t: Map.get(filter, "created_t")
      },
      sort: %{
        size: Map.get(sort, "size"), 
        type: Map.get(sort, "type"), 
        created: Map.get(sort, "created")
      }
    }

    adapter_0 = UserGettingById
    adapter_1 = FileGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          AppLogger.info("Получен список файлов")

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
    adapter_1 = FileGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, file} -> 
          AppLogger.info("Получен файл")

          Success.handle(conn, file)
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