defmodule NodeNotifier.Notifier do
  use GenServer
  require Logger

  @developer_email Application.compile_env(:node_notifier, :developer_email)
  @name_node Application.compile_env(:node_notifier, :name_node)

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def init(state), do: {:ok, state}

  def handle_info({:for_user, message}, state) do
    {:ok, true} = SmtpAdapters.Notifier.notify(message)
    
    ModLogger.Logger.info(%{
      message: "Отправлено собщение пользователю на электронную почту", 
      node: @name_node
    })

    {:noreply, state}
  end

  # notify developer by telegram
  def handle_info({:for_developer, message}, state) do
    {:ok, true} = SmtpAdapters.Notifier.notify(
      Map.put(message, :to, @developer_email)
    )

    ModLogger.Logger.info(%{
      message: "Отправлено собщение разработчику на электронную почту", 
      node: @name_node
    })

    {:noreply, state}
  end

  def handle_info(_info, state) do
    {:noreply, state}
  end
end