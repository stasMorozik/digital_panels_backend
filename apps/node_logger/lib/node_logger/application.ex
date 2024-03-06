defmodule NodeLogger.Application do
  use Application

  def start(_type, _args) do
    children = [
      NodeLogger.Logger
    ]

    opts = [strategy: :one_for_one, name: NodeLogger.Supervisor]
    Supervisor.start_link(children, opts)
  end
end