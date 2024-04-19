defmodule NodeWebsocketDevice.WebsocketHandler do

  alias Core.Device.UseCases.Updating
  
  alias PostgresqlAdapters.Device.Updating, as: DeviceUpdating
  alias PostgresqlAdapters.Device.GettingById, as: DeviceGettingById
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById

  alias NodeWebsocketDevice.WebsocketServer

  @where {
    Application.compile_env(:node_api, :name_process), 
    Application.compile_env(:node_api, :name_node)
  }

  @behaviour :cowboy_websocket

  @impl true
  def init(req, _state) do
    state = %{
      headers: req.headers,
      qs: req.qs
    }
    {:cowboy_websocket, req, state, %{idle_timeout: :infinity}}
  end

  @impl true
  def websocket_init(state) do
    a_0 = UserGettingById
    a_1 = GroupGettingById
    a_2 = DeviceGettingById
    a_3 = DeviceUpdating

    try do
      with cookie <- Map.get(state.headers, "cookie"),
           false <- cookie == nil,
           map <- Cookie.parse(cookie),
           access_token <- Map.get(map, "access_token"),
           map <- URI.decode_query(state.qs),
           group_id <- Map.get(map, "group_id"),
           false <- group_id == nil,
           id <- Map.get(map, "id"),
           false <- id == nil,
           args <- %{
             token: access_token, 
             id: id, 
             group_id: group_id,
             is_active: true
           },
           {:ok, true} <- Updating.update(a_0, a_1, a_2, a_3, args) do

        WebsocketServer.join({group_id, self()})

        NodeWebsocketDevice.Logger.info("Устройство авторизовано и подключено к websocket серверу")

        :ok = Process.send(
          @where, {:notify_all, %{
            id: id, 
            message: "Устройство активно", 
            is_active: true
          }}, []
        )

        {:ok, %{
          group_id: group_id,
          id: id,
          access_token: access_token
        }}
      else
        true ->
            NodeWebsocketDevice.Logger.error("Невалидный данные для подключения")

            {:reply, {:close, 1000, "Невалидный даынне для подключения"}, nil}

        {:error, message} -> 

          NodeWebsocketDevice.Logger.error(message)

          {:reply, {:close, 1000, message}, state}
      end
    rescue e -> 
      NodeWebsocketDevice.Logger.exception(e)

      NodeWebsocketDevice.NotifierAdmin.notify(e)

      {:reply, {:close, 1000, "Что то пошло не так"}, nil}
    end
  end

  @impl true
  def terminate(_reason, _partial_req, state) do
    leave()
    # try do
    #   with cookie <- Map.get(state.headers, "cookie"),
    #        false <- cookie == nil,
    #        map <- Cookie.parse(cookie),
    #        access_token <- Map.get(map, "access_token"),
    #        map <- URI.decode_query(state.qs),
    #        group_id <- Map.get(map, "group_id"),
    #        false <- group_id == nil,
    #        id <- Map.get(map, "id"),
    #        false <- id == nil,
    #        args <- %{
    #           token: access_token, 
    #           id: id, 
    #           group_id: group_id,
    #           is_active: false
    #          },
    #          {:ok, true} <- Updating.update(
    #             UserGettingById, 
    #             GroupGettingById, 
    #             DeviceGettingById, 
    #             DeviceUpdating, 
    #             args
    #          ) do

    #       NodeWebsocketDevice.Logger.info("Устройство одключено от websocket сервера")

    #       :ok = Process.send(
    #         @where, {:notify_all, %{
    #           id: id, 
    #           message: "Устройство не активно", 
    #           is_active: false
    #         }}, []
    #       )

    #       leave()
    #     else
    #       true ->
    #         NodeWebsocketDevice.Logger.error("Невалидный данные для отключения")

    #         {:reply, {:close, 1000, "Невалидный данные для отключения"}, nil}

    #         leave()
    #       {:error, message} -> 
    #         NodeWebsocketDevice.Logger.error(message)

    #         leave()
    #     end
    # rescue e -> 
    #   NodeWebsocketDevice.Logger.exception(e)

    #   # NodeWebsocketDevice.NotifierAdmin.notify(e)

    #   leave()
    # end
  end

  defp leave() do
    WebsocketServer.leave(self())
    :ok
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
  def websocket_info({:notify, message}, state) do
    {:reply, {:text, message}, state}
  end

  @impl true
  def websocket_info(_info, state) do
    {:ok, state}
  end
end