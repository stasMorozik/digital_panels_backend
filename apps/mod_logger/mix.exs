defmodule ModLogger.MixProject do
  use Mix.Project

  def project do
    [
      app: :mod_logger,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "./config/config.exs",
      deps_path: "./../../deps",
      lockfile: "./../../mix.lock",
      elixir: "~> 1.15.0-rc.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  def application do
    [
      extra_applications: [:logger, :mnesia]
    ]
  end

  defp deps do
    [
      
    ]
  end

  defp elixirc_paths(:test), do: [
    "lib"
  ]
  defp elixirc_paths(_), do: ["lib"]
end
