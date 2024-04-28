defmodule NodeWebsocketDevice.MixProject do
  use Mix.Project

  def project do
    [
      app: :node_websocket_device,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "./config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {NodeWebsocketDevice.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:jason, "~> 1.2"},
      {:plug_cowboy, "~> 2.7"},
      {:cookie, "~> 0.1.2"},
      {:core, in_umbrella: true},
      {:postgresql_adapters, in_umbrella: true},
      {:amqp, "~> 3.3"},
      {:uri, "~> 0.1.0"},
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"]
    ]
  end
end
