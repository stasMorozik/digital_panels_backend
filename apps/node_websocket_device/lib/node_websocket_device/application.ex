defmodule NodeWebsocketDevice.Application do

  use Application

  def start(_type, _args) do
    :ets.new(:connections, [:set, :public, :named_table])

    children = [
      {
        Plug.Cowboy, 
        scheme: :http, 
        plug: NodeWebsocketDevice.Router, 
        options: [
          port: cowboy_port(),
          dispatch: dispatch()
        ]
      },
      %{
        id: NodeWebsocketDevice.Postgres,
        start: {NodeWebsocketDevice.Postgres, :start_link, []}
      },
      NodeWebsocketDevice.GenServers.Websocket,
      %{
        id: NodeWebsocketDevice.GenServers.Consumer,
        start: {NodeWebsocketDevice.GenServers.Consumer, :start_link, []}
      },
    ]

    opts = [strategy: :one_for_one, name: NodeWebsocketDevice.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:node_websocket_device, :cowboy_port)

  defp dispatch do
    [
      {:_, [
        {"/ws", NodeWebsocketDevice.Handlers.Websocket, []}
      ]}
    ]
  end
end