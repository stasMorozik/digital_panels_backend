defmodule NodeApi.WebsocketHandler do

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById

  alias NodeApi.WebsocketServer

  @behaviour :cowboy_websocket

  @impl true
  def init(req, _state) do
    {:cowboy_websocket, req, req.headers, %{idle_timeout: :infinity}}
  end

  @impl true
  def websocket_init(state) do
    try do
      with cookie <- Map.get(state, "cookie"),
           false <- cookie == nil,
           map <- Cookie.parse(cookie),
           access_token <- Map.get(map, "access_token"),
           args <- %{token: access_token},
           {:ok, _} <- Authorization.auth(UserGettingById, args) do

        NodeApi.Logger.info("Пользователь авторизован")

        WebsocketServer.join(self())

        {:ok, state}
      else
        true ->
          NodeApi.Logger.error("Невалидные куки")

          {:reply, {:close, 1000, "Невалидные куки"}, nil}

        {:error, message} -> 
          NodeApi.Logger.error(message)

          {:reply, {:close, 1000, message}, nil}
      end
    rescue e -> 
      NodeApi.NotifierAdmin.notify(e)

      NodeApi.Logger.exception(e)

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
  def websocket_info({:notify, message}, state) do
    {:reply, {:text, message}, state}
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