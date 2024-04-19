import Config

config :joken, default_signer: "secret"

config :core, 
  email_address: "digital_panels@dev.org",
  url_web_dav: "http://192.168.0.107:8100/upload"

config :postgresql_adapters,
  hostname: "192.168.0.107",
  username: "db_user",
  password: "12345",
  database: "system_content_manager",
  port: 5437,
  secret_key: "!qazSymKeyXsw2"