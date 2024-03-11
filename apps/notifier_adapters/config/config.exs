import Config

config :notifier_adapters, 
  name_node: String.to_atom("node_notifier@debian"),
  name_process: NodeNotifier.Notifier