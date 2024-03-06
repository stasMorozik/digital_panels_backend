defmodule NodeNotifier.Application do
  use Application

  def start(_type, _args) do
    children = [
      NodeNotifier.Notifier
    ]

    opts = [strategy: :one_for_one, name: NodeNotifier.Supervisor]
    Supervisor.start_link(children, opts)
  end
end