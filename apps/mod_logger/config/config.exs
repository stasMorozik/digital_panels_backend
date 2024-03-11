import Config

config :mod_logger, 
  name_node: String.to_atom("node_logger@debian"),
  name_process: NodeLogger.Logger
