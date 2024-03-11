defmodule NodeAssemblyMaker.Maker do
  use GenServer
  require Logger

  @name_node Application.compile_env(:node_assembly_maker, :name_node)

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_info({:make, message}, state) do
    ModLogger.Logger.info(%{
      message: "Получено задание на компиляцию сборки", 
      node: @name_node
    })

    Logger.info(message)

    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end
end