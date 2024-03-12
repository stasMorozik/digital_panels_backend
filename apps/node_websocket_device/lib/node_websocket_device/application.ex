defmodule NodeWebsocketDevice.Application do

  use Application

  @name_node_logger Application.compile_env(:mod_logger, :name_node)
  @name_node_notifier Application.compile_env(:notifier_adapters, :name_node)

  def start(_type, _args) do
    :ets.new(:connections, [:set, :public, :named_table])

    :pong = :net_adm.ping(@name_node_logger)
    :pong = :net_adm.ping(@name_node_notifier)

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
      %{
        id: NodeWebsocketDevice.WebsocketServer,
        start: {NodeWebsocketDevice.WebsocketServer, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: NodeWebsocketDevice.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:node_websocket_device, :cowboy_port)

  defp dispatch do
    [
      {:_, [
        {"/ws/**/", NodeWebsocketDevice.WebsocketHandler, []}
      ]}
    ]
  end
end