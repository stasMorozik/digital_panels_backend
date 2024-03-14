defmodule NodeApi.Application do

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
        plug: NodeApi.Router, 
        options: [
          port: cowboy_port(),
          dispatch: dispatch()
        ]
      },
      %{
        id: NodeApi.Postgres,
        start: {NodeApi.Postgres, :start_link, []}
      },
      NodeApi.WebsocketServer,
      NodeApi.AssemblyCompiler
    ]

    opts = [strategy: :one_for_one, name: NodeApi.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:node_api, :cowboy_port)

  defp dispatch do
    [
      {:_, [
        {"/ws", NodeApi.WebsocketHandler, []},
        {:_, Plug.Cowboy.Handler, {NodeApi.Router, []}}
      ]}
    ]
  end
end