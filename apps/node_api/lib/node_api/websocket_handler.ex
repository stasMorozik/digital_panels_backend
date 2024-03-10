defmodule NodeApi.WebsocketHandler do

  alias NodeApi.WebsocketServer

  @behaviour :cowboy_websocket

  @impl true
  def init(req, _state) do
    {:cowboy_websocket, req, nil, %{idle_timeout: :infinity}}
  end

  @impl true
  def websocket_init(_state) do
    state = %{}
    WebsocketServer.join(self())
    {:ok, state}
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