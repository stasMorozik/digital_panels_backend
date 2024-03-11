defmodule NodeNotifier.Application do
  use Application

  @name_node_logger Application.compile_env(:mod_logger, :name_node)

  def start(_type, _args) do
    :pong = :net_adm.ping(@name_node_logger)
    
    children = [
      NodeNotifier.Notifier
    ]

    opts = [strategy: :one_for_one, name: NodeNotifier.Supervisor]
    Supervisor.start_link(children, opts)
  end
end