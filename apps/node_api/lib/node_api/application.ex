defmodule NodeApi.Application do
  use Application

  @name_node_logger Application.compile_env(:node_api, :name_node_logger)
  @name_node_notifier Application.compile_env(:node_api, :name_node_notifier)

  def start(_type, _args) do
    :ets.new(:connections, [:set, :public, :named_table])

    :pong = :net_adm.ping(@name_node_logger)

    :pong = :net_adm.ping(@name_node_notifier)

    children = [
      {
        Plug.Cowboy, scheme: :http, plug: NodeApi.Router, options: [port: cowboy_port()]
      },
      %{
        id: NodeApi.Postgres,
        start: {NodeApi.Postgres, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: NodeApi.Supervisor]

    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:example, :cowboy_port, 8080)
end