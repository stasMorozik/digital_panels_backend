defmodule NodeLogger.Logger do
  use GenServer
  require Logger

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_info({:exception, message}, state) do
    Logger.warning(message)

    {:noreply, state}
  end

  def handle_info({:info, message}, state) do
    Logger.info(message)

    {:noreply, state}
  end

  def handle_info({:debug, message}, state) do
    Logger.debug(message)

    {:noreply, state}
  end
end