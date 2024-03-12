defmodule NodeApi.WebsocketHandler do

  alias Core.User.UseCases.Authorization
  alias PostgresqlAdapters.User.GettingById, as: UserGettingById

  @name_node Application.compile_env(:node_api, :name_node)
  @to Application.compile_env(:node_api, :developer_telegram_login)
  @from Application.compile_env(:core, :email_address)

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
           map <- Cookie.parse(cookie),
           access_token <- Map.get(map, "access_token"),
           args <- %{token: access_token},
           {:ok, _} <- Authorization.auth(UserGettingById, args) do
        ModLogger.Logger.info(%{
          message: "Пользователь авторизован и подключен к websocket серверу",
          node: @name_node
        })

        WebsocketServer.join(self())

        {:ok, state}
      else
        nil -> 
          ModLogger.Logger.info(%{
            message: "Пользователь не прошел авторизацию и не подключен к websocket серверу. Невалидный токен",
            node: @name_node
          })

          {:reply, {:close, 1000, "Invalid token"}, nil}
        {:error, message} -> 
          ModLogger.Logger.info(%{
            message: "Пользователь не прошел авторизацию и не подключен к websocket серверу. #{message}",
            node: @name_node
          })

          {:reply, {:close, 1000, "Invalid token"}, nil}
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
  def websocket_info({:device_updated, message}, state) do
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