defmodule AdminPanel.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      AdminPanelWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: AdminPanel.PubSub},
      # Start the Endpoint (http/https)
      AdminPanelWeb.Endpoint
      # Start a worker by calling: AdminPanel.Worker.start_link(arg)
      # {AdminPanel.Worker, arg}
    ]

    {:ok, pid} = AdminPanelConsumer.start_link()

    :ets.new(:access_tokens, [:set, :public, :named_table])
    :ets.new(:refresh_tokens, [:set, :public, :named_table])
    :ets.new(:admin_sockets, [:set, :public, :named_table])
    :ets.new(:connections, [:set, :public, :named_table])

    {:ok, pid} = Postgrex.start_link(
      hostname: Application.fetch_env!(:postgresql_adapters, :hostname),
      username: Application.fetch_env!(:postgresql_adapters, :username),
      password: Application.fetch_env!(:postgresql_adapters, :password),
      database: Application.fetch_env!(:postgresql_adapters, :database),
      port: Application.fetch_env!(:postgresql_adapters, :port)
    )

    :ets.insert(:connections, {"postgresql", "", pid})

    opts = [strategy: :one_for_one, name: AdminPanel.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AdminPanelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
