import Config

config :core, 
  email_address: "digital_panels@dev.org",
  url_web_dav: "http://192.168.0.161:8100/upload"

config :http_adapters,
  user_web_dav: "user",
  password_web_dav: "12345"
