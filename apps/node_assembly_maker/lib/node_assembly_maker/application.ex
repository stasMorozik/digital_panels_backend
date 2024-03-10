defmodule NodeAssemblyMaker.Application do
  use Application

  def start(_type, _args) do
    children = [
      NodeAssemblyMaker.Maker
    ]

    opts = [strategy: :one_for_one, name: NodeAssemblyMaker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end