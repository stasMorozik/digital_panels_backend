defmodule AdminPanel.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AdminPanelWeb.Telemetry,
      {Phoenix.PubSub, name: AdminPanel.PubSub},
      AdminPanelWeb.Endpoint,
      %{
        id: AdminPanelConsumer,
        start: {AdminPanelConsumer, :start_link, []}
      },
      %{
        id: AdminPanelDB,
        start: {AdminPanelDB, :start_link, []}
      },
    ]

    :ets.new(:access_tokens, [:set, :public, :named_table])
    :ets.new(:refresh_tokens, [:set, :public, :named_table])
    :ets.new(:admin_sockets, [:set, :public, :named_table])
    :ets.new(:connections, [:set, :public, :named_table])
    :ets.insert(:admin_sockets, {"pids", "", []})

    opts = [strategy: :one_for_one, name: AdminPanel.Supervisor]

    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    AdminPanelWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
