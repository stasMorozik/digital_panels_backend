import Config

config :mod_logger, 
  name_node: String.to_atom("node_logger@debian"),
  name_process: NodeLogger.Logger

config :node_notifier,
  name_node: String.to_atom("node_notifier@debian"),
  developer_email: "stanim857@gmail.com"

config :smtp_adapters, SmtpAdapters.Mailer,
  adapter: Swoosh.Adapters.Sendmail,
  cmd_path: "sendmail",
  cmd_args: "",
  qmail: true