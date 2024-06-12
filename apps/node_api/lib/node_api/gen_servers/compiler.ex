defmodule NodeApi.GenServers.Compiler do
  
  use GenServer

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
  def handle_cast({:compile, args}, state) do
    spawn(fn -> 
      try do
        adapter_0 = PostgresqlAdapters.Assembly.GettingById
        adapter_1 = SqliteAdapters.Assembly.Inserting
        adapter_2 = HttpAdapters.Assembly.Uploading
        adapter_3 = PostgresqlAdapters.Assembly.Updating

        case Compiling.compile(adapter_0, adapter_1, adapter_2, adapter_3, args) do
          {:ok, true} -> 
            NodeApi.Logger.info("Сборка скомпилирована")

            json = Jason.encode!(%{
              type: "assembly",
              id: args.id, 
              status: true
            })

            NodeApi.GenServers.Websocket.broadcast(json)

          {:error, message} ->
            NodeApi.Logger.info(message)
        end
      rescue e -> 
        NodeApi.Logger.exception(e.message)

        NodeApi.Notifiers.Admin.notify(e.message)
      end
    end)
    {:noreply, state}
  end
end