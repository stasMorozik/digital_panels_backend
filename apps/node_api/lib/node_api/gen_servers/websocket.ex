defmodule NodeApi.GenServers.Websocket do

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
    {:noreply, [pid | state]}
  end

  @impl true
  def handle_cast({:leave, pid}, state) do
    {:noreply, state -- [pid]}
  end

  @impl true
  def handle_cast({:notify_all, message}, state) do
    clients = state
    Enum.each(clients, &send(&1, {:notify, message}))
    {:noreply, state}
  end
end