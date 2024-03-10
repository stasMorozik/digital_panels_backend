defmodule NodeAssemblyMaker.Maker do
  use GenServer
  require Logger

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_info({:make, message}, state) do
    Logger.info(message)

    {:noreply, state}
  end

  @impl true
  def handle_info(_info, state) do
    {:noreply, state}
  end
end