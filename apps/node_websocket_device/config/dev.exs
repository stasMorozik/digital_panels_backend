import Config

config :joken, 
  default_signer: "!qazSymKeyXsw2"

config :postgresql_adapters,
  hostname: "192.168.0.161",
  username: "db_user",
  password: "12345",
  database: "system_content_manager",
  port: 5437,
  secret_key: "!qazSymKeyXsw2"


config :mod_logger, 
  name_node: String.to_atom("node_logger@debian"),
  name_process: NodeLogger.Logger

config :notifier_adapters, 
  name_node: String.to_atom("node_notifier@debian"),
  name_process: NodeNotifier.Notifier

config :node_api, 
  name_node: String.to_atom("node_api@debian"),
  name_process: NodeApi.WebsocketServer

config :node_websocket_device, 
  name_node: String.to_atom("node_websocket_device@debian"),
  name_process: NodeWebsocketDevice.WebsocketServer,
  cowboy_port: 8081

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
