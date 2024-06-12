defmodule NodeApi.Controllers.File do

  alias Core.File.UseCases.Creating
  alias Core.File.UseCases.Getting
  alias Core.File.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.File.Inserting, as: FileInserting
  alias HttpAdapters.File.Uploading, as: FileUploading
  alias PostgresqlAdapters.File.GettingById, as: FileGettingById
  alias PostgresqlAdapters.File.GettingList, as: FileGettingList

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
        message = "Создан файл"
        payload = true

        NodeApi.Handlers.Success.handle(conn, payload, message)
      else
        true ->
          NodeApi.Handlers.Error.handle(conn, "Нет файла для загрузки")
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
        type: Map.get(filter, "type"),
        url: Map.get(filter, "url"),
        extension: Map.get(filter, "extension"), 
        size: NodeApi.Utils.Parsers.Integer.parse(filter, "size"),
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
          message = "Получен список файлов"
          payload = Enum.map(list, fn (file) -> %{
            id: file.id,
            url: file.url,
            extension: file.extension,
            type: file.type,
            size: file.size,
            created: file.created
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
    adapter_1 = FileGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, file} -> 
          message = "Получен файл"
          payload = %{
            id: file.id,
            path: file.path,
            url: file.url,
            extension: file.extension,
            type: file.type,
            size: file.size,
            created: file.created
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