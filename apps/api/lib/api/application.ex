defmodule Api.Application do
  use Application
  require Logger

  def start(_type, _args) do
    :ets.new(:connections, [:set, :public, :named_table])

    :pong = :net_adm.ping(String.to_atom("node_logger@debian"))

    children = [
      {
        Plug.Cowboy, scheme: :http, plug: Api.Router, options: [port: cowboy_port()]
      },
      %{
        id: Api.Postgres,
        start: {Api.Postgres, :start_link, []}
      }
    ]

    opts = [strategy: :one_for_one, name: Api.Supervisor]

    Logger.info("Starting application...")

    Supervisor.start_link(children, opts)
  end

  defp cowboy_port, do: Application.get_env(:example, :cowboy_port, 8080)
end