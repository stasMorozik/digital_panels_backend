defmodule NodeApi.Application do

  use Application

  def start(_type, _args) do
    :ets.new(:connections, [:set, :public, :named_table])

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
      NodeApi.AssemblyCompiler,
      %{
        id: NodeApi.Consumer,
        start: {NodeApi.Consumer, :start_link, []}
      },
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