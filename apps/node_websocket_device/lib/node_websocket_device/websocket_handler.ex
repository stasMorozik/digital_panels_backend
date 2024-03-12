defmodule NodeWebsocketDevice.WebsocketHandler do

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById

  @name_node Application.compile_env(:node_api, :name_node)

  alias NodeWebsocketDevice.WebsocketServer

  @behaviour :cowboy_websocket

  @impl true
  def init(req, _state) do
    {:cowboy_websocket, req, req.headers, %{idle_timeout: :infinity}}
  end

  @impl true
  def websocket_init(state) do
    with cookie <- Map.get(state, "cookie"),
         map <- Cookie.parse(cookie),
         access_token <- Map.get(map, "access_token"),
         args <- %{token: access_token},
         {:ok, _} <- Authorization.auth(UserGettingById, args) do
      ModLogger.Logger.info(%{
        message: "Устройство авторизовано и подключено к websocket серверу",
        node: @name_node
      })

      WebsocketServer.join(self())

      {:ok, state}
    else
      nil -> {:reply, {:close, 1000, "Invalid token"}, nil}
      {:error, _} -> {:reply, {:close, 1000, "Invalid token"}, nil}
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
  def terminate(_reason, _partial_req, _state) do
    WebsocketServer.leave(self())
    :ok
  end
end