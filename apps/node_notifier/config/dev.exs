import Config

config :node_notifier, 
  developer_email: "stanim857@gmail.com" 

config :smtp_adapters, SmtpAdapters.Mailer,
  adapter: Swoosh.Adapters.Sendmail,
  cmd_path: "sendmail",
  cmd_args: "-N delay,failure,success",
  qmail: true