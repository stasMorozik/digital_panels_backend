defmodule NodeApi.AssemblyCompiler do
  
  use GenServer

  alias Core.Assembly.UseCases.Compiling

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def make(id) do
    GenServer.cast(__MODULE__, {:make, id})
  end

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
    task = Task.async(fn -> 
      # case Compiling.compile(
      #   PostgresqlAdapters.Assembly.GettingById,
      #   HttpAdapters.Assembly.Uploading,
      #   PostgresqlAdapters.Assembly.Updating,
      # ) do
      #   {:ok, true} -> 

      #   {:error, message} ->
          
      # end
    end)
    {:noreply, new_state}
  end
end