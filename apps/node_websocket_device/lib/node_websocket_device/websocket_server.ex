defmodule NodeWebsocketDevice.WebsocketServer do

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def join(pid) do
    GenServer.cast(__MODULE__, {:join, pid})
  end

  def leave(pid) do
    GenServer.cast(__MODULE__, {:leave, pid})
  end

  # def broadcast(message) do
  #   GenServer.cast(__MODULE__, {:notify_device, message})
  # end

  @impl true
  def terminate(_reason, _state) do
    :ok
  end

  @impl true
  def init(_opts \\ []) do
    state = []
    {:ok, state}
  end
  
  @impl true
  def handle_info(_info, state) do
    {:noreply, state}
  end

  @impl true
  def handle_cast({:join, {group_id, pid}}, state) do
    {:noreply, [{group_id, pid} | state]}
  end

  @impl true
  def handle_cast({:leave, excess_pid}, state) do
    fun = fn ({_, pid}) -> 
      pid != excess_pid 
    end

    {:noreply, Enum.filter(state, fun)}
  end

  @impl true
  def handle_cast({:notify_device, message}, state) do
    fun = fn({group_id, pid}) -> 
      if group_id == Map.get(message, :group_id) do 
        send(pid, {:notify, message}) 
      end 
    end

    Enum.each(state, fun)
    
    {:noreply, state}
  end
end