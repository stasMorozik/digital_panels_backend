import Config

config :smtp_adapters, SmtpAdapters.Mailer,
  adapter: Swoosh.Adapters.Sendmail,
  cmd_path: "sendmail",
  cmd_args: "-N delay,failure,success",
  qmail: true
