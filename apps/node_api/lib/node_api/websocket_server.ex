defmodule NodeApi.WebsocketServer do

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

  def broadcast(message) do
    GenServer.cast(__MODULE__, {:notify_all, message})
  end

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
  def handle_cast({:join, pid}, state) do
    current_clients = state
    new_state = [pid | current_clients]
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:leave, pid}, state) do
    all_clients = state
    others = all_clients -- [pid]
    new_state = others
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:notify_all, message}, state) do
    clients = state
    Enum.each(clients, &send(&1, {:new_hit, message}))
    {:noreply, state}
  end

  @impl true
  def handle_call({:clients_count}, _from, state) do
    {:reply, {:ok, Enum.count(state)}, state}
  end
end