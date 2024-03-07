import Config

config :joken, 
  default_signer: "!qazSymKeyXsw2"

config :core, 
  email_address: "digital_panels@dev.org",
  url_web_dav: "http://192.168.0.161:8100/upload"

config :http_adapters,
  user_web_dav: "user",
  password_web_dav: "12345"

config :postgresql_adapters,
  hostname: "192.168.0.161",
  username: "db_user",
  password: "12345",
  database: "system_content_manager",
  port: 5437,
  secret_key: "!qazSymKeyXsw2"

config :node_api, 
  cowboy_port: 8080,
  name_node_logger: String.to_atom("node_logger@debian"),
  name_process_logger: NodeLogger.Logger,
  name_node_notifier: String.to_atom("node_notifier@debian"),
  name_process_notifier: NodeNotifier.Notifier,
  developer_telegram_login: "@Stanm858",
  name_node_api: String.to_atom("node_api@debian")

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
