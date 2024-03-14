import Config

config :joken, default_signer: "secret"

config :core, 
  email_address: "digital_panels@dev.org",
  url_web_dav: "http://192.168.0.161:8100/upload"

config :sqlite_adapters,
  path_android_bundle: "/home/bundles/b_an/",
  path_linux_bundle: "/home/bundles/b_li/",
  path_windows_bundle: "/home/bundles/b_wi/"