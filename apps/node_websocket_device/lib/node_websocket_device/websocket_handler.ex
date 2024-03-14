defmodule NodeWebsocketDevice.WebsocketHandler do

  alias Core.Device.UseCases.Updating
  
  alias PostgresqlAdapters.Device.Updating, as: DeviceUpdating
  alias PostgresqlAdapters.Device.GettingById, as: DeviceGettingById
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById

  @name_node Application.compile_env(:node_websocket_device, :name_node)
  @idle_timeout Application.compile_env(:node_websocket_device, :idle_timeout)
  @to Application.compile_env(:node_websocket_device, :developer_telegram_login)
  @from Application.compile_env(:core, :email_address)

  @where {
    Application.compile_env(:node_api, :name_process), 
    Application.compile_env(:node_api, :name_node)
  }

  alias NodeWebsocketDevice.WebsocketServer

  @behaviour :cowboy_websocket

  @impl true
  def init(req, _state) do
    {:cowboy_websocket, req, %{
      headers: req.headers,
      qs: req.qs
    }, %{idle_timeout: @idle_timeout}}
  end

  @impl true
  def websocket_init(state) do
    try do
      with  cookie <- Map.get(state.headers, "cookie"),
            map <- Cookie.parse(cookie),
            access_token <- Map.get(map, "access_token"),
            map <- URI.decode_query(state.qs),
            group_id <- Map.get(map, "group_id"),
            id <- Map.get(map, "id"),
            args <- %{
              token: access_token, 
              id: id, 
              group_id: group_id,
              is_active: true
            },
            {:ok, true} <- Updating.update(
              UserGettingById, 
              GroupGettingById, 
              DeviceGettingById, 
              DeviceUpdating, 
              args
            ) do
        WebsocketServer.join(self())

        ModLogger.Logger.info(%{
          message: "Устройство авторизовано и подключено к websocket серверу",
          node: @name_node
        })

        :ok = Process.send(
          @where, {:notify_all, Jason.encode!(%{
            id: id, 
            message: "Устройство активно", 
            is_active: true
            })}, []
        )

        {:ok, state}
      else
        nil -> 
          ModLogger.Logger.info(%{
            message: "Устройство не прошло авторизацию. Невалидный токен",
            node: @name_node
          })

          {:reply, {:close, 1000, "Устройство не прошло авторизацию"}, state}
        {:error, message} -> 
          ModLogger.Logger.info(%{
            message: "Устройство не прошло авторизацию. #{message}",
            node: @name_node
          })

          {:reply, {:close, 1000, "Устройство не прошло авторизацию"}, state}
      end
    rescue e -> 
      ModLogger.Logger.info(%{
        message: e,
        node: @name_node
      })

      NotifierAdapters.SenderToDeveloper.notify(%{
        to: @to,
        from: @from,
        subject: "Exception",
        message: e
      })

      {:reply, {:close, 1000, "Что то пошло не так"}, nil}
    end
  end

  @impl true
  def websocket_handle({:text, "ping"}, state) do
    {:reply, {:text, "pong"}, state}
  end

  @impl true
  def websocket_handle({:text, _msg}, state) do
    {:ok, state}
  end

  @impl true
  def websocket_info(_info, state) do
    {:ok, state}
  end

  @impl true
  def terminate(_reason, _partial_req, state) do
    try do
      with cookie <- Map.get(state.headers, "cookie"),
           map <- Cookie.parse(cookie),
           access_token <- Map.get(map, "access_token"),
           map <- URI.decode_query(state.qs),
           group_id <- Map.get(map, "group_id"),
           id <- Map.get(map, "id"),
           args <- %{
              token: access_token, 
              id: id, 
              group_id: group_id,
              is_active: false
             },
             {:ok, true} <- Updating.update(
                UserGettingById, 
                GroupGettingById, 
                DeviceGettingById, 
                DeviceUpdating, 
                args
             ) do
          WebsocketServer.join(self())

          ModLogger.Logger.info(%{
            message: "Устройство одключено от websocket сервера",
            node: @name_node
          })

          :ok = Process.send(
            @where, {:notify_all, Jason.encode!(%{
              id: id, 
              is_active: false,
              message: "Устройство не активно"
            })}, []
          )

          leave()
        else
          {:error, message} -> 
            ModLogger.Logger.info(%{
              message: "Устройство одключено от websocket сервера. #{message}",
              node: @name_node
            })

            leave()
        end
    rescue e -> 
      ModLogger.Logger.info(%{
        message: e,
        node: @name_node
      })

      leave()
    end
  end

  defp leave() do
    WebsocketServer.leave(self())
    :ok
  end
end