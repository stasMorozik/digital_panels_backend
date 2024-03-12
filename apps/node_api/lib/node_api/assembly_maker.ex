defmodule NodeApi.AssemblyMaker do
  
  use GenServer

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
  def handle_cast({:make, id}, state) do
    task = Task.async(fn -> 
      
    end)
    {:noreply, new_state}
  end
end