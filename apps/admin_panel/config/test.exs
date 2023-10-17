import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :admin_panel, AdminPanelWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "Yz9nGQ35hOtMcM5/EEyD0LY17K/HU0kkzabY1BACvY1TsxDQ+LmOXnPgaNoIynRE",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
