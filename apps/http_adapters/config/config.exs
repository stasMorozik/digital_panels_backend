import Config

config :joken, default_signer: "secret"

config :core, 
  email_address: "digital_panels@dev.org",
  url_web_dav: "http://192.168.0.161:8100/upload"

config :http_adapters,
  user_web_dav: "user",
  password_web_dav: "12345",
  path_android_bundle: "/home/bundles/b_an/",
  path_linux_bundle: "/home/bundles/b_li/",
  path_windows_bundle: "/home/bundles/b_wi/"

config :exqlite, default_chunk_size: 100
