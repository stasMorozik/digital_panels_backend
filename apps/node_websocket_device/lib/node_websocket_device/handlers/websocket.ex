defmodule NodeWebsocketDevice.Handlers.Websocket do

  alias Core.Device.UseCases.Updating
  
  alias PostgresqlAdapters.Device.Updating, as: DeviceUpdating
  alias PostgresqlAdapters.Device.GettingById, as: DeviceGettingById
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById
  alias PostgresqlAdapters.Group.GettingById, as: GroupGettingById

  @behaviour :cowboy_websocket

  alias NodeWebsocketDevice.Notifiers.Admin
  alias NodeWebsocketDevice.Notifiers.Node
  alias NodeWebsocketDevice.Logger, as: AppLogger
  alias NodeWebsocketDevice.GenServers.Websocket

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

        Websocket.join({group_id, self()})

        AppLogger.info("Устройство авторизовано и подключено к websocket серверу")

        Node.notify(%{type: "device", id: id, is_active: true})

        {:ok, %{
          group_id: group_id,
          id: id,
          access_token: access_token
        }}
      else
        true ->
            AppLogger.error("Невалидный данные для подключения")

            {:reply, {:close, 1000, "Невалидный даынне для подключения"}, nil}

        {:error, message} -> 
          AppLogger.error(message)

          {:reply, {:close, 1000, message}, state}
      end
    rescue e -> 
      AppLogger.exception(e.message)

      Admin.notify(e.message)

      {:reply, {:close, 1000, "Что то пошло не так"}, nil}
    end
  end

  @impl true
  def terminate(_reason, _partial_req, state) do
    a_0 = UserGettingById
    a_1 = GroupGettingById
    a_2 = DeviceGettingById
    a_3 = DeviceUpdating

    try do
      with access_token <- Map.get(state, "access_token"),
           id <- Map.get(state, "id"),
           group_id <- Map.get(state, "group_id"),
           false <- access_token == nil,
           false <- id == nil,
           false <- group_id == nil,
           args <- %{
              token: access_token, 
              id: id, 
              group_id: group_id,
              is_active: false
           },
           {:ok, true} <- Updating.update(a_0, a_1, a_2, a_3, args) do

          AppLogger.info("Устройство одключено от websocket сервера")

          Node.notify(%{type: "device", id: id, is_active: false})
          
          leave()
        else
          true ->
            AppLogger.error("Невалидный данные для отключения")

            {:reply, {:close, 1000, "Невалидный данные для отключения"}, nil}

            leave()
          {:error, message} -> 
            AppLogger.error(message)

            leave()
        end
    rescue e -> 
      AppLogger.exception(e.message)

      Admin.notify(e.message)

      leave()
    end
  end

  defp leave() do
    Websocket.leave(self())
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