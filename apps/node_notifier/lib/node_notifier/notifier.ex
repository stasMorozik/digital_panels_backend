defmodule NodeNotifier.Notifier do
  use GenServer
  require Logger

  @developer_email Application.compile_env(:node_notifier, :developer_email)

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_info({:for_user, message}, state) do
    Logger.info(message)

    {:ok, true} = SmtpAdapters.Notifier.notify(message)

    {:noreply, state}
  end

  # notify developer by telegram
  def handle_info({:for_developer, message}, state) do
    Logger.info(message)
    
    {:ok, true} = SmtpAdapters.Notifier.notify(Map.put(message, :to, @developer_email))

    {:noreply, state}
  end
end