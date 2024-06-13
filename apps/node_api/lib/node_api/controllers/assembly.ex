defmodule NodeApi.Controllers.Assembly do
  alias Core.Assembly.UseCases.Creating
  alias Core.Assembly.UseCases.Getting
  alias Core.Assembly.UseCases.GettingList
  alias Core.User.UseCases.Authorization

  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Assembly.Inserting, as: AssemblyInserting
  alias PostgresqlAdapters.Assembly.GettingById, as: AssemblyGettingById
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById
  alias PostgresqlAdapters.Assembly.GettingList, as: AssemblyGettingList

  alias NodeApi.Handlers.Success
  alias NodeApi.Handlers.Error
  alias NodeApi.Handlers.Exception
  alias NodeApi.GenServers.Compiler
  alias NodeApi.Logger, as: AppLogger
  alias NodeApi.Utils.Parsers.Integer
  alias NodeApi.Utils.Parsers.Boolean

  defmodule AssemblyPipe do
    
    alias Core.Shared.Ports.Pipe

    @behaviour Pipe

    @impl Pipe
    def emit(%{id: id,user: user}) do
      Compiler.compile(%{
        id: id,
        user: user
      })

      {:ok, true}
    end
  end

  def create(conn) do
    args = %{
      group_id: Map.get(conn.body_params, "group_id"),
      type: Map.get(conn.body_params, "type"),
      token: Map.get(conn.cookies, "access_token")
    }

    adapter_0 = UserGettingById
    adapter_1 = GroupGettingById
    adapter_2 = AssemblyInserting
    adapter_3 = AssemblyPipe

    try do
      case Creating.create(adapter_0, adapter_1, adapter_2, adapter_3, args) do
        {:ok, true} ->
          AppLogger.info("Создана сборка и отправлена на компиляцию")
          
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
    try do
      with token <- Map.get(conn.cookies, "access_token"),
           args <- %{token: token},
           adapter_0 <- UserGettingById,
           {:ok, user} <- Authorization.auth(adapter_0, args) do
          Compiler.compile(%{
            id: id,
            user: user
          })

          AppLogger.info("Сборка отправлена на компиляцию")

          Success.handle(conn, true)
        else
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
        url: Map.get(filter, "url"),
        type: Map.get(filter, "type"),
        group: Map.get(filter, "group"),
        status: Boolean.parse(filter, "status"),
        created_f: Map.get(filter, "created_f"), 
        created_t: Map.get(filter, "created_t")
      },
      sort: %{
        type: Map.get(sort, "type"), 
        created: Map.get(sort, "created")
      }
    }

    adapter_0 = UserGettingById
    adapter_1 = AssemblyGettingList

    try do
      case GettingList.get(adapter_0, adapter_1, args) do
        {:ok, list} -> 
          AppLogger.info("Получен список сборок")

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
    adapter_1 = AssemblyGettingById

    try do
      case Getting.get(adapter_0, adapter_1, args) do
        {:ok, assembly} -> 
          AppLogger.info("Получена сборка")
          
          Success.handle(conn, assembly)
        {:error, message} -> 
          Error.handle(conn, message)
        {:exception, message} -> 
          Exception.handle(conn, message)
      end
    rescue
      e-> Exception.handle(conn, Map.get(e, :message))
    end
  end
end