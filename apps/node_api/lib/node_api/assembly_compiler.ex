defmodule NodeApi.AssemblyCompiler do
  
  use GenServer

  @name_node Application.compile_env(:node_api, :name_node)
  @to Application.compile_env(:node_api, :developer_telegram_login)
  @from Application.compile_env(:core, :email_address)

  alias Core.Assembly.UseCases.Compiling

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def compile(message) do
    GenServer.cast(__MODULE__, {:compile, message})
  end

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def terminate(_reason, _state) do
    :ok
  end

  @impl true
  def handle_info(_info, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:compile, %{id: id, user: user}}, state) do
    Task.async(fn -> 
      try do
        case Compiling.compile(
          PostgresqlAdapters.Assembly.GettingById,
          SqliteAdapters.Assembly.Inserting,
          HttpAdapters.Assembly.Uploading,
          PostgresqlAdapters.Assembly.Updating,
          %{id: id, user: user}
        ) do
          {:ok, true} -> 
            ModLogger.Logger.info(%{
              message: "Сборка скомпилирована", 
              node: @name_node
            })

            NodeApi.WebsocketServer.broadcast(Jason.encode!(%{
              id: id, 
              message: "Сборка скомпилирована"
            }))

          {:error, message} ->
            
            ModLogger.Logger.info(%{
              message: message, 
              node: @name_node
            })
        end
      rescue e -> 
        ModLogger.Logger.exception(%{
          message: e, 
          node: @name_node
        })

        NotifierAdapters.SenderToDeveloper.notify(%{
          to: @to,
          from: @from,
          subject: "Exception",
          message: e
        })
      end
    end)
    {:noreply, state}
  end
end