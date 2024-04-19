import Config

config :amqp,
  connections: [
    conn: [url: "amqp://user:12345@192.168.0.107:5672"],
  ],
  channels: [
    chann: [connection: :conn]
  ]

config :joken, 
  default_signer: "!qazSymKeyXsw2"

config :core, 
  email_address: "digital_panels@dev.org",
  url_web_dav: "http://192.168.0.107:8100/upload"

config :http_adapters,
  user_web_dav: "user",
  password_web_dav: "12345",
  path_android_bundle: "/home/bundles/b_an/",
  path_linux_bundle: "/home/bundles/b_li/",
  path_windows_bundle: "/home/bundles/b_wi/"

config :sqlite_adapters,
  path_android_bundle: "/home/bundles/b_an/",
  path_linux_bundle: "/home/bundles/b_li/",
  path_windows_bundle: "/home/bundles/b_wi/"

config :postgresql_adapters,
  hostname: "192.168.0.107",
  username: "db_user",
  password: "12345",
  database: "system_content_manager",
  port: 5437,
  secret_key: "!qazSymKeyXsw2"


config :node_api, 
  name_node: String.to_atom("node_api@debian"),
  name_process: NodeApi.WebsocketServer,
  cowboy_port: 8080

config :websocket_device, 
  name_node: String.to_atom("node_websocket_device@debian"),
  name_process: NodeWebsocketDevice.Server

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]
