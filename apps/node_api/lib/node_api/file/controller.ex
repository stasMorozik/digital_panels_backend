defmodule NodeApi.File.Controller do

  alias Core.File.UseCases.Creating
  alias Core.File.UseCases.Getting
  alias Core.File.UseCases.GettingList

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.File.Inserting, as: FileInserting
  alias HttpAdapters.File.Uploading, as: FileUploading
  alias PostgresqlAdapters.File.GettingById, as: FileGettingById
  alias PostgresqlAdapters.File.GettingList, as: FileGettingList

  @name_node Application.compile_env(:node_api, :name_node)

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

        ModLogger.Logger.info(%{
          message: "Создан файл", 
          node: @name_node
        })

        conn |> Plug.Conn.send_resp(200, Jason.encode!(true))
      else
        true -> 
          NodeApi.Handlers.handle_error(conn, "Нет файла для загрузки", 400)
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
        type: Map.get(filter, "type"),
        url: Map.get(filter, "url"),
        extension: Map.get(filter, "extension"), 
        size: NodeApi.Utils.integer_parse(filter, "size"),
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
          ModLogger.Logger.info(%{
            message: "Получен список файлов", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(
            Enum.map(list, fn (file) -> 
              %{
                id: file.id,
                url: file.url,
                extension: file.extension,
                type: file.type,
                size: file.size,
                created: file.created
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
    adapter_1 = FileGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, file} -> 
          ModLogger.Logger.info(%{
            message: "Получен файл", 
            node: @name_node
          })

          conn |> Plug.Conn.send_resp(200, Jason.encode!(%{
            id: file.id,
            path: file.path,
            url: file.url,
            extension: file.extension,
            type: file.type,
            size: file.size,
            created: file.created
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